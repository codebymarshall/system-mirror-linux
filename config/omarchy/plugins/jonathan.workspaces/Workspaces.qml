import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "jonathan.workspaces"

  readonly property var workspaceNames: ["Home", "Work", "Dev", "Office", "Gaming", "Media", "Comms"]

  function workspaceByName(name) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].name === name) return values[i]
    }

    return null
  }

  function visibleWorkspaceNames() {
    var names = []
    for (var i = 0; i < root.workspaceNames.length; i++) {
      var name = root.workspaceNames[i]
      var workspace = root.workspaceByName(name)
      var occupied = workspace !== null && workspace.toplevels.values.length > 0
      var focused = Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.name === name
      if (occupied || focused) names.push(name)
    }

    return names
  }

  function focusWorkspace(name) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"name:" + name + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.visibleWorkspaceNames().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.visibleWorkspaceNames()

      WidgetButton {
        required property string modelData

        readonly property var workspace: root.workspaceByName(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.name === modelData

        bar: root.bar
        text: modelData
        active: focused
        opacity: 1
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : -1
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
