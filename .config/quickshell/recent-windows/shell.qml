import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root
    property var state: ({opened: false, windows: [], index: 0})
    property var windows: state.windows || []
    property int selected: state.index || 0
    property bool opened: state.opened === true && windows.length > 0
    // Quick Alt+Tab taps switch without flashing the overlay.
    property bool shown: false
    onOpenedChanged: { shown = false; if (opened) showDelay.restart(); else showDelay.stop() }
    Timer { id: showDelay; interval: 200; onTriggered: root.shown = true }
    function readState() {
        try { root.state = JSON.parse(data.text()) }
        catch (e) { root.state = ({opened: false, windows: [], index: 0}) }
    }
    function sourceFor(address) {
        let all = Hyprland.toplevels.values
        for (let i = 0; i < all.length; i++) {
            if (all[i].address.replace(/^0x/, "") === address.replace(/^0x/, ""))
                return all[i].wayland
        }
        return null
    }
    function iconFor(app) {
        if (app.toLowerCase().indexOf("unity") !== -1) return "unityhub"
        if (app === "zen") return "zen-browser"
        if (app.indexOf("omarchy.agent") !== -1) return "utilities-terminal"
        return app.toLowerCase()
    }
    FileView {
        id: data
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/recent-window-switcher.json"
        watchChanges: true
        onLoaded: root.readState()
        onFileChanged: reload()
        onLoadFailed: root.state = ({opened: false, windows: [], index: 0})
    }
    PanelWindow {
        id: panel
        visible: root.shown
        screen: Quickshell.screens.find(s => s.name === root.state.monitorName) || Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "recent-window-switcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        mask: Region { item: popup }
        Rectangle {
            id: popup
            readonly property int columns: Math.max(1, Math.min(root.windows.length, Math.floor((panel.width - 120) / 246)))
            readonly property int rows: Math.ceil(root.windows.length / columns)
            width: columns * 246 + 32
            height: rows * 194 + 65
            anchors.centerIn: parent
            radius: 18
            color: "#f0262832"
            border.color: "#626877"
            border.width: 1
            Grid {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 18
                columns: popup.columns
                rowSpacing: 10
                columnSpacing: 10
                Repeater {
                    model: root.windows
                    Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        width: 236
                        height: 184
                        radius: 10
                        readonly property bool lit: index === root.selected || mouse.containsMouse
                        color: mouse.pressed ? "#5a6582" : lit ? "#454d61" : "#30333e"
                        border.width: lit ? 3 : 1
                        border.color: lit ? "#9acbff" : "#505563"
                        scale: mouse.pressed ? 0.96 : 1
                        Behavior on scale { NumberAnimation { duration: 40 } }
                        Behavior on color { ColorAnimation { duration: 40 } }
                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            onClicked: event => {
                                if (event.button === Qt.MiddleButton) {
                                    Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/recent-window-switcher", "close:" + card.modelData.address])
                                    return
                                }
                                // Hide now instead of waiting for the script's state write.
                                root.state = ({opened: false, windows: [], index: 0})
                                Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/recent-window-switcher", "choose:" + card.modelData.address])
                            }
                        }
                        Row {
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                            spacing: 9
                            Image {
                                width: 20; height: 20
                                source: Quickshell.iconPath(root.iconFor(card.modelData.class), "application-x-executable")
                            }
                            Text {
                                width: 174
                                text: card.modelData.title || card.modelData.class
                                color: "#f4f5fa"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            anchors { top: parent.top; topMargin: 44; bottom: parent.bottom; bottomMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                            radius: 5
                            color: "#1b1d25"
                            clip: true
                            ScreencopyView {
                                id: preview
                                anchors.centerIn: parent
                                captureSource: root.sourceFor(card.modelData.address)
                                live: root.opened
                                constraintSize: Qt.size(parent.width, parent.height)
                                width: implicitWidth
                                height: implicitHeight
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !preview.hasContent
                                text: card.modelData.class
                                color: "#c1c6d4"
                                font.pixelSize: 15
                            }
                        }
                    }
                }
            }
            Text {
                anchors { bottom: parent.bottom; bottomMargin: 13; horizontalCenter: parent.horizontalCenter }
                text: "Hold Alt · Tab to choose · Middle-click to close · Release Alt to switch"
                color: "#bac1d1"
                font.pixelSize: 12
            }
        }
    }
}
