import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import vm from "node:vm"
import test from "node:test"

function loadTimerModel() {
  const source = readFileSync(
    new URL("../config/omarchy/plugins/jonathan.movement-breaks/TimerModel.js", import.meta.url),
    "utf8",
  ).replace(/^\.pragma library\s*/, "")
  const context = {}
  vm.createContext(context)
  vm.runInContext(source, context)
  return context
}

test("a delayed break tick finishes the workout instead of freezing it", () => {
  const timer = loadTimerModel()
  const result = timer.advance(true, "break", true, 5, 0, 15_000)

  assert.equal(result.remainingSeconds, 0)
  assert.equal(result.transition, "finish-break")
})

test("a delayed work tick does not count suspended computer time", () => {
  const timer = loadTimerModel()
  const result = timer.advance(true, "work", false, 60, 0, 15_000)

  assert.equal(result.remainingSeconds, 60)
  assert.equal(result.transition, "")
})

test("idle pauses work time but not an active movement break", () => {
  const timer = loadTimerModel()

  assert.equal(timer.advance(true, "work", true, 60, 0, 1_000).remainingSeconds, 60)
  assert.equal(timer.advance(true, "break", true, 60, 0, 1_000).remainingSeconds, 59)
})
