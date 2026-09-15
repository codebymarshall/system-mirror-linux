import QtQuick
import Quickshell.Io
import Quickshell.Wayland
import "TimerModel.js" as TimerModel

Item {
  id: root

  // Injected by omarchy-shell. The timer itself is a singleton service so
  // multiple monitors never create duplicate countdowns or notifications.
  property var shell: null

  readonly property var presets: ({
    "health-30": {
      label: "Health 30 / 5",
      workSeconds: 30 * 60,
      breakSeconds: 5 * 60,
      summary: "5 minutes of movement after 30 active minutes"
    },
    "focus-50": {
      label: "Focus 50 / 5",
      workSeconds: 50 * 60,
      breakSeconds: 5 * 60,
      summary: "5 minutes of movement after 50 active minutes"
    }
  })

  readonly property var activities: [
    {
      title: "Brisk walk",
      instruction: "Step away from the screen and walk briskly for 5 minutes."
    },
    {
      title: "Squats + walk",
      instruction: "Do 8–12 controlled chair squats or sit-to-stands, then walk gently for the rest of the 5 minutes."
    },
    {
      title: "Push + walk",
      instruction: "Do 8–12 wall or sturdy-desk push-ups, then walk gently for the rest of the 5 minutes."
    },
    {
      title: "March + calf raises",
      instruction: "March in place for 3 minutes, do 10–15 calf raises, then keep moving until 5 minutes are up."
    },
    {
      title: "Walk + mobility",
      instruction: "Walk for 4 minutes, then finish with gentle shoulder rolls and comfortable upper-body stretches."
    }
  ]

  property string preset: "health-30"
  property bool timerRunning: false
  property string phase: "work"
  property int remainingSeconds: presets[preset].workSeconds
  property int activityIndex: 0
  property string activityTitle: "Brisk walk"
  property string activityInstruction: activities[0].instruction
  property double lastTickMs: Date.now()
  property string queuedSound: ""

  readonly property string soundHelperPath: Qt.resolvedUrl("play-sound")
    .toString()
    .replace(/^file:\/\//, "")

  readonly property bool away: idleMonitor.isIdle
  readonly property bool pausedForIdle: phase === "work" && away
  readonly property var activePreset: presets[preset]
  readonly property string presetLabel: activePreset.label
  readonly property string presetSummary: activePreset.summary
  readonly property string phaseLabel: pausedForIdle && timerRunning
    ? "Away — timer paused"
    : !timerRunning
      ? "Paused"
      : phase === "break" ? "Movement break" : "Active computer work"
  readonly property string countdown: formatDuration(remainingSeconds)
  readonly property string barLabel: pausedForIdle && timerRunning ? "IDLE" : countdown

  function normalizePreset(value) {
    return value === "focus-50" ? "focus-50" : "health-30"
  }

  function formatDuration(totalSeconds) {
    var safe = Math.max(0, Math.floor(Number(totalSeconds) || 0))
    var minutes = Math.floor(safe / 60)
    var seconds = safe % 60
    var paddedMinutes = minutes < 10 ? "0" + minutes : String(minutes)
    var paddedSeconds = seconds < 10 ? "0" + seconds : String(seconds)
    return paddedMinutes + ":" + paddedSeconds
  }

  function configure(nextPreset, nextEnabled) {
    var normalized = normalizePreset(nextPreset)
    var shouldRun = nextEnabled === true || nextEnabled === "true"

    if (normalized !== preset) {
      preset = normalized
      resetWork(false)
    }

    if (shouldRun !== timerRunning) setEnabled(shouldRun, false)
  }

  function setPreset(nextPreset) {
    var normalized = normalizePreset(nextPreset)
    if (normalized === preset) return
    preset = normalized
    resetWork(false)
  }

  function setEnabled(value, announce) {
    var next = value === true
    if (next === timerRunning) return
    timerRunning = next
    lastTickMs = Date.now()
    if (announce) {
      sendNotification(
        next ? "Movement timer resumed" : "Movement timer paused",
        next ? presetSummary : "The active-work countdown is paused.",
        "low"
      )
    }
  }

  function resetWork(announce) {
    phase = "work"
    remainingSeconds = presets[preset].workSeconds
    lastTickMs = Date.now()
    if (announce) {
      sendNotification(
        "Focus interval reset",
        presetSummary + ". The countdown starts now.",
        "low"
      )
    }
  }

  function chooseActivity() {
    var selected = activities[activityIndex % activities.length]
    activityIndex = (activityIndex + 1) % activities.length
    activityTitle = selected.title
    activityInstruction = selected.instruction
  }

  function beginMovementBreak() {
    chooseActivity()
    timerRunning = true
    phase = "break"
    remainingSeconds = activePreset.breakSeconds
    lastTickMs = Date.now()
    sendNotification(
      "Time to move — 5 minutes",
      activityInstruction + "\n\nStop or modify the activity if you feel pain, dizziness, unusual shortness of breath, or instability.",
      "normal"
    )
    playSound("break-start")
  }

  function completeMovementBreak() {
    phase = "work"
    remainingSeconds = activePreset.workSeconds
    lastTickMs = Date.now()
    sendNotification(
      "Movement break complete",
      "Return to work when ready. Your next active-work interval starts now.",
      "low"
    )
    playSound("break-end")
  }

  function tick() {
    var now = Date.now()
    var next = TimerModel.advance(
      timerRunning,
      phase,
      away,
      remainingSeconds,
      lastTickMs,
      now
    )
    lastTickMs = next.lastTickMs
    remainingSeconds = next.remainingSeconds

    if (next.transition === "start-break") beginMovementBreak()
    else if (next.transition === "finish-break") completeMovementBreak()
  }

  function sendNotification(title, body, urgency) {
    var command = [
      "omarchy-notification-send",
      "--app-name", "movement-breaks",
      "-g", "󰔛",
      "-u", urgency || "normal",
      "-t", "30000",
      title,
      body
    ]

    if (notificationProcess.running) {
      queuedNotification = command
      return
    }

    notificationProcess.command = command
    notificationProcess.running = true
  }

  function playSound(eventName) {
    if (soundProcess.running) {
      queuedSound = eventName
      return
    }

    soundProcess.command = [soundHelperPath, eventName]
    soundProcess.running = true
  }

  property var queuedNotification: []

  Process {
    id: notificationProcess
    command: []
    onExited: function() {
      if (!root.queuedNotification || root.queuedNotification.length === 0) return
      command = root.queuedNotification
      root.queuedNotification = []
      running = true
    }
  }

  Process {
    id: soundProcess
    command: []
    onExited: function() {
      if (!root.queuedSound) return
      command = [root.soundHelperPath, root.queuedSound]
      root.queuedSound = ""
      running = true
    }
  }

  // Three minutes matches this machine's existing screensaver threshold.
  // Idle time pauses active computer work but never an active movement break.
  IdleMonitor {
    id: idleMonitor
    enabled: root.timerRunning
    timeout: 180
    respectInhibitors: false
    onIsIdleChanged: root.lastTickMs = Date.now()
  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: root.tick()
  }

  IpcHandler {
    target: "jonathan.movement-breaks"

    function testSound(): string {
      root.playSound("break-end")
      return "ok"
    }

    function status(): string {
      return JSON.stringify({
        preset: root.preset,
        running: root.timerRunning,
        away: root.away,
        phase: root.phase,
        remainingSeconds: root.remainingSeconds,
        countdown: root.countdown,
        activity: root.phase === "break" ? root.activityTitle : ""
      })
    }
  }
}
