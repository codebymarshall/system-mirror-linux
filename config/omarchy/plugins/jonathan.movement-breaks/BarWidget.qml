import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "jonathan.movement-breaks"

  readonly property var service: bar && bar.shell
    ? bar.shell.serviceFor(moduleName) : null
  readonly property string selectedPreset: setting("preset", "health-30") === "focus-50"
    ? "focus-50" : "health-30"
  readonly property bool configuredRunning: {
    var value = setting("running", true)
    return value === true || value === "true"
  }
  readonly property string glyph: "󰔛"

  property bool popupOpen: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property bool opened: popupOpen

  function open() { popupOpen = true }
  function close() { popupOpen = false }
  function togglePanel() { popupOpen = !popupOpen }
  function closeForPopoutSwitch() { close() }

  function syncService() {
    if (service) service.configure(selectedPreset, configuredRunning)
  }

  function writeSetting(key, value) {
    var entry = { id: moduleName }
    var current = settings && typeof settings === "object" ? settings : ({})
    for (var name in current) {
      if (name !== "id") entry[name] = current[name]
    }
    entry[key] = value
    settings = entry

    if (bar && bar.shell && typeof bar.shell.updateEntryInline === "function")
      bar.shell.updateEntryInline(moduleName, entry)
  }

  function choosePreset(value) {
    var normalized = value === "focus-50" ? "focus-50" : "health-30"
    writeSetting("preset", normalized)
    if (service) service.setPreset(normalized)
  }

  function setRunning(value, announce) {
    writeSetting("running", value === true)
    if (service) service.setEnabled(value === true, announce === true)
  }

  function toggleRunning() {
    var next = service ? !service.timerRunning : !configuredRunning
    setRunning(next, true)
  }

  function resetWork() {
    if (service) service.resetWork(true)
  }

  function moveNow() {
    writeSetting("running", true)
    if (service) service.beginMovementBreak()
  }

  onServiceChanged: syncService()
  onSettingsChanged: syncService()
  Component.onCompleted: Qt.callLater(syncService)

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.vertical
      ? root.glyph
      : root.glyph + " " + (root.service ? root.service.barLabel : "--:--")
    active: root.service && root.service.phase === "break" && root.service.timerRunning
    dimmed: root.service ? !root.service.timerRunning : !root.configuredRunning
    tooltipText: root.service
      ? "Movement Breaks · " + root.service.presetLabel
        + "\n" + root.service.phaseLabel + " · " + root.service.countdown
        + "\nLeft: controls · Right: pause/resume · Middle: move now"
      : "Movement Breaks is loading"

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.toggleRunning()
      else if (mouseButton === Qt.MiddleButton) root.moveNow()
      else root.togglePanel()
    }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: fittedContentWidth(Style.space(340))
    contentHeight: fittedContentHeight(contentColumn.implicitHeight)

    Column {
      id: contentColumn
      anchors.fill: parent
      spacing: Style.space(12)

      Text {
        width: parent.width
        text: "MOVEMENT BREAKS"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        width: parent.width
        text: root.service ? root.service.countdown : "--:--"
        color: root.service && root.service.phase === "break"
          ? root.bar.urgent : root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.displayLarge
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        width: parent.width
        text: root.service ? root.service.phaseLabel : "Loading timer…"
        color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.68)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        width: parent.width
        visible: root.service && root.service.phase === "break"
        text: root.service
          ? root.service.activityTitle + "\n" + root.service.activityInstruction : ""
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      Text {
        width: parent.width
        text: "BREAK CADENCE"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
      }

      Row {
        width: parent.width
        spacing: Style.space(8)

        Button {
          width: (parent.width - parent.spacing) / 2
          text: "30 work / 5 move"
          foreground: root.bar.foreground
          selected: root.selectedPreset === "health-30"
          onClicked: root.choosePreset("health-30")
        }

        Button {
          width: (parent.width - parent.spacing) / 2
          text: "50 work / 5 move"
          foreground: root.bar.foreground
          selected: root.selectedPreset === "focus-50"
          onClicked: root.choosePreset("focus-50")
        }
      }

      Text {
        width: parent.width
        text: root.selectedPreset === "health-30"
          ? "Default: the stronger tested interruption dose for prolonged sitting."
          : "Screen-work option aligned with short, frequent occupational breaks."
        color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.68)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      Row {
        width: parent.width
        spacing: Style.space(8)

        Button {
          width: (parent.width - parent.spacing) / 2
          text: root.service && root.service.timerRunning ? "Pause" : "Start"
          iconText: root.service && root.service.timerRunning ? "󰏤" : "󰐊"
          foreground: root.bar.foreground
          selected: root.service && root.service.timerRunning
          onClicked: root.toggleRunning()
        }

        Button {
          width: (parent.width - parent.spacing) / 2
          text: "Reset focus"
          iconText: "󰑐"
          foreground: root.bar.foreground
          onClicked: root.resetWork()
        }
      }

      Button {
        width: parent.width
        text: "Move now"
        iconText: "󰝊"
        foreground: root.bar.foreground
        onClicked: root.moveNow()
      }

      Text {
        width: parent.width
        text: "No custom times: only the fixed 30/5 and 50/5 presets. The countdown pauses after 3 minutes of computer inactivity. Stop or modify any movement that causes pain or dizziness."
        color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.58)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
    }
  }
}
