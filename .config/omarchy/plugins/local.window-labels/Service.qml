import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Toggle: omarchy-shell windowlabels toggle
Item {
  id: root

  property var shell: null
  property bool shown: false
  property var labels: []

  // While shown, an Omarchy Hyprland toggle file widens the gap above every
  // window by labelHeight (defaults: gaps_in 5, gaps_out 10) so labels sit
  // in that gap instead of over content, like a groupbar.
  readonly property int labelHeight: 20
  readonly property string gapsFile: Quickshell.env("HOME") + "/.local/state/omarchy/toggles/hypr/window-labels.lua"

  function setGaps(on) {
    Quickshell.execDetached(["bash", "-c", on
      ? "mkdir -p \"${1%/*}\" && echo 'hl.config({ general = { gaps_in = { top = " + (5 + labelHeight + 4) + ", right = 5, bottom = 5, left = 5 }, gaps_out = { top = " + (10 + labelHeight + 4) + ", right = 10, bottom = 10, left = 10 } } })' > \"$1\" && hyprctl reload"
      : "[ -f \"$1\" ] && rm \"$1\" && hyprctl reload", "_", gapsFile])
  }

  // A shell restart drops `shown`, so drop a leftover gap file with it.
  Component.onCompleted: setGaps(false)

  IpcHandler {
    target: "windowlabels"
    function toggle(): string {
      root.shown = !root.shown
      root.setGaps(root.shown)
      if (root.shown) probe.running = true
      return root.shown ? "on" : "off"
    }
  }

  // ponytail: polls hyprctl every 300ms while shown; switch to Hyprland.rawEvent if that ever matters
  Timer {
    interval: 300
    repeat: true
    running: root.shown
    onTriggered: if (!probe.running) probe.running = true
  }

  // One TSV row per window on a visible (active or special) workspace:
  // monitor, x, y relative to that monitor, width, pid, program, title.
  Process {
    id: probe
    command: ["bash", "-c",
      "jq -r -n --argjson c \"$(hyprctl -j clients)\" --argjson m \"$(hyprctl -j monitors)\" " +
      "'$m[] as $o | $c[] | select(.mapped and .monitor == $o.id and (.workspace.id == $o.activeWorkspace.id or .workspace.id == $o.specialWorkspace.id)) " +
      "| [$o.name, .at[0] - $o.x, .at[1] - $o.y, .size[0], .pid, .title] | @tsv' | " +
      "while IFS=$'\\t' read -r mon x y w pid title; do " +
      "printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' \"$mon\" \"$x\" \"$y\" \"$w\" \"$pid\" \"$(cat /proc/$pid/comm 2>/dev/null)\" \"$title\"; done"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.labels = text.split("\n").filter(l => l).map(l => {
        const f = l.split("\t")
        return { monitor: f[0], x: +f[1], y: +f[2], w: +f[3], pid: f[4], program: f[5], title: f.slice(6).join("\t") }
      })
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property var modelData
      screen: modelData
      visible: root.shown
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "omarchy-window-labels"
      mask: Region {}

      Repeater {
        model: root.labels.filter(l => l.monitor === win.modelData.name)

        Rectangle {
          required property var modelData
          width: Math.min(text.implicitWidth, modelData.w - 32) + 16
          x: modelData.x + (modelData.w - width) / 2
          y: modelData.y - height - 4
          height: root.labelHeight
          radius: 4
          color: "#cc000000"

          Text {
            id: text
            anchors.centerIn: parent
            width: parent.width - 16
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            color: "white"
            font.family: "monospace"
            font.pixelSize: 12
            text: parent.modelData.title + "  ·  " + parent.modelData.program + " · pid " + parent.modelData.pid
          }
        }
      }
    }
  }
}
