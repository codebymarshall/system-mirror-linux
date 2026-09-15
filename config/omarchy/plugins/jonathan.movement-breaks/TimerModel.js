.pragma library

function advance(timerRunning, phase, away, remainingSeconds, lastTickMs, nowMs) {
  var elapsedSeconds = Math.max(1, Math.floor((nowMs - lastTickMs) / 1000))
  var result = {
    remainingSeconds: remainingSeconds,
    lastTickMs: nowMs,
    transition: ""
  }

  if (!timerRunning || (phase === "work" && away)) return result

  // A delayed work tick means the machine suspended or the shell stalled, so
  // it cannot represent active computer time. A movement break uses elapsed
  // wall-clock time and must finish even when the screensaver delayed a tick.
  if (phase === "work" && elapsedSeconds > 10) return result

  result.remainingSeconds = Math.max(0, remainingSeconds - elapsedSeconds)
  if (result.remainingSeconds === 0)
    result.transition = phase === "work" ? "start-break" : "finish-break"

  return result
}
