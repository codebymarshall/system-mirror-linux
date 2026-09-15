-- GlazeWM keybinding port from the SystemMirror repository, using SUPER for
-- imported bindings unless an ALT binding is explicitly defined below.

-- Remove Omarchy defaults that occupy SystemMirror's SUPER combinations.
-- The comments document the prior action for each overridden key.
local system_mirror_overrides = {
  "SUPER + LEFT",                 -- was: Focus left
  "SUPER + RIGHT",                -- was: Focus right
  "SUPER + UP",                   -- was: Focus up
  "SUPER + DOWN",                 -- was: Focus down
  "SUPER + SHIFT + LEFT",         -- was: Swap window left
  "SUPER + SHIFT + RIGHT",        -- was: Swap window right
  "SUPER + SHIFT + UP",           -- was: Swap window up
  "SUPER + SHIFT + DOWN",         -- was: Swap window down
  "SUPER + O",                    -- was: Pop window out
  "SUPER + L",                    -- was: Toggle workspace layout
  "SUPER + F",                    -- was: Full screen
  "SUPER + T",                    -- was: Toggle floating/tiling
  "SUPER + SHIFT + SPACE",        -- was: Toggle top bar
  "SUPER + RETURN",               -- was: Terminal
  "SUPER + W",                    -- was: Close window
  "SUPER + K",                    -- was: Keybindings
  "SUPER + SHIFT + A",            -- was: ChatGPT
  "SUPER + SHIFT + F",            -- was: File manager
  "SUPER + SHIFT + D",            -- was: Docker
  "SUPER + SHIFT + S",            -- was: Google Maps
  "SUPER + SHIFT + W",            -- was: Omawrite
  "SUPER + SHIFT + E",            -- was: Email
  "SUPER + SHIFT + P",            -- was: Google Photos
  "SUPER + CTRL + R",             -- was: Set reminder
  "SUPER + CTRL + X",             -- was: Toggle dictation
}

for _, key in ipairs(system_mirror_overrides) do
  hl.unbind(key)
end

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
end

-- Focus windows.
o.bind("SUPER + LEFT", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + RIGHT", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + UP", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + DOWN", "Focus down", hl.dsp.focus({ direction = "d" }))

-- Move windows within the current workspace.
o.bind("SUPER + SHIFT + LEFT", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + RIGHT", "Move window right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + UP", "Move window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + DOWN", "Move window down", hl.dsp.window.swap({ direction = "d" }))

-- Resize in 40-pixel increments. ALT+O/P form a left-to-right decrease/increase pair.
o.bind("ALT + O", "Decrease window width", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
o.bind("ALT + P", "Increase window width", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
o.bind("SUPER + U", "Shrink window width", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
o.bind("SUPER + O", "Grow window height", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
o.bind("SUPER + I", "Shrink window height", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })

-- Window management.
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + T", "Toggle tiling/floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SHIFT + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + L", "Toggle workspace layout", "system-mirror-workspace-layout-toggle")
o.bind("SUPER + D", "Application launcher", "omarchy-menu toggle apps")

-- Applications. Cursor is intentionally not assigned a dedicated binding.
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + W", "Browser", { omarchy = "browser" })
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
if o.cmd_present("lazygit") then
  o.bind("ALT + G", "LazyGit (current repository)", "omarchy launch terminal system-mirror-lazygit")
end

-- Workspaces mirror the SystemMirror GlazeWM display names.
local workspaces = { "Home", "Work", "Dev", "Office", "Gaming", "Media", "Comms" }
for index, workspace in ipairs(workspaces) do
  local key = "code:" .. tostring(index + 9)
  local target = "name:" .. workspace
  o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = target }))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = target }))
end

-- e±1 traverses only currently open workspaces. Empty named workspaces are not
-- persistent, so keyboard and MX thumb-wheel navigation skip them.
o.bind("SUPER + A", "Previous active workspace", hl.dsp.focus({ workspace = "e-1" }))

o.bind("SUPER + SHIFT + A", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + F", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + D", "Docker", { tui = "omarchy-launch-docker-tui" })
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- System and configuration.
local home = os.getenv("HOME") or "/home/jonathan"
o.bind("SUPER + K", "Keybindings", home .. "/.local/bin/omarchy-menu-keybindings-mx")
o.bind("SUPER + SHIFT + R", "Reload Hyprland config", "hyprctl reload")
o.bind("SUPER + SHIFT + W", "Reload renderer", hl.dsp.force_renderer_reload())
o.bind("SUPER + SHIFT + E", "Exit Hyprland", hl.dsp.exit())
o.bind("SUPER + CTRL + R", "Restart system", "omarchy-system-reboot")
o.bind("SUPER + CTRL + X", "Shut down system", "omarchy-system-shutdown")

-- Dictation.
if o.cmd_present("voxtype") then
  hl.unbind("SUPER + CTRL + Z")
  hl.unbind("SUPER + CTRL + V")
  o.bind("SUPER + CTRL + V", "Toggle dictation", "voxtype record toggle")
end

-- Pause all compositor keybindings until SUPER+SHIFT+P is pressed again.
o.bind("SUPER + SHIFT + P", "Pause keybindings", hl.dsp.submap("system-mirror-pause"))
hl.define_submap("system-mirror-pause", function()
  o.bind("SUPER + SHIFT + P", "Resume keybindings", hl.dsp.submap("reset"))
end)
