-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Omarchy persists per-workspace layout rules below XDG state and requires
-- them as modules. Add the state root so those modules survive config reloads.
local state_home = os.getenv("XDG_STATE_HOME") or ((os.getenv("HOME") or "/home/jonathan") .. "/.local/state")
package.path = state_home .. "/?.lua;" .. package.path

-- Load Omarchy defaults, then the SystemMirror-managed user overrides.
require("default.hypr.omarchy")
require("hypr.monitors")
require("hypr.input")

-- Reload these modules on every Hyprland reload so changes apply immediately.
package.loaded["hypr.bindings"] = nil
package.loaded["hypr.window-rules"] = nil
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.window-rules")

require("default.hypr.toggles")
