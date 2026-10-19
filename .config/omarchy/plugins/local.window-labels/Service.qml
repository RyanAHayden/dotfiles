import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// Toggle: omarchy-shell windowlabels toggle
Item {
  id: root

  property var shell: null
  property bool shown: false
  property var programs: ({}) // pid -> /proc/<pid>/comm

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
      if (root.shown) refresh.restart()
      return root.shown ? "on" : "off"
    }
  }

  // Window geometry and pids live in lastIpcObject, which only updates on
  // refreshToplevels(). Refresh on any Hyprland event (coalesced), plus every
  // second for resizes, which emit no event. Workspace switches need no
  // refresh: the monitor's activeWorkspace is tracked live.
  Connections {
    target: Hyprland
    enabled: root.shown
    function onRawEvent(event) { refresh.restart() }
  }

  Timer {
    id: refresh
    interval: 16
    onTriggered: {
      Hyprland.refreshToplevels()
      Hyprland.refreshMonitors()
      root.fetchPrograms()
    }
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.shown
    onTriggered: refresh.restart()
  }

  function fetchPrograms() {
    const missing = Hyprland.toplevels.values
      .map(t => t.lastIpcObject.pid)
      .filter(pid => pid > 0 && !(pid in root.programs))
    if (missing.length === 0 || comm.running) return
    comm.command = ["bash", "-c", "for p; do printf '%s\\t%s\\n' \"$p\" \"$(cat /proc/$p/comm 2>/dev/null)\"; done", "_"].concat(missing.map(String))
    comm.running = true
  }

  Process {
    id: comm
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        const next = Object.assign({}, root.programs)
        text.split("\n").filter(l => l).forEach(l => {
          const f = l.split("\t")
          next[f[0]] = f[1]
        })
        root.programs = next
      }
    }
  }

  function visibleOn(t, screenName) {
    const ws = t.workspace
    const mon = t.monitor
    if (!ws || !mon || mon.name !== screenName || !t.lastIpcObject.mapped) return false
    // Grouped windows already show their title in the groupbar.
    if ((t.lastIpcObject.grouped || []).length > 0) return false
    if (ws === mon.activeWorkspace) return true
    const special = mon.lastIpcObject.specialWorkspace
    return !!special && special.id === ws.id
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
        model: root.shown ? Hyprland.toplevels.values.filter(t => root.visibleOn(t, win.modelData.name)) : []

        Rectangle {
          required property var modelData
          readonly property var ipc: modelData.lastIpcObject
          readonly property int w: ipc.size ? ipc.size[0] : 0
          width: Math.min(text.implicitWidth, w - 32) + 16
          x: (ipc.at ? ipc.at[0] : 0) - win.modelData.x + (w - width) / 2
          y: (ipc.at ? ipc.at[1] : 0) - win.modelData.y - height - 4
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
            text: parent.modelData.title + "  ·  " + (root.programs[parent.ipc.pid] || "?") + " · pid " + parent.ipc.pid
          }
        }
      }
    }
  }
}
