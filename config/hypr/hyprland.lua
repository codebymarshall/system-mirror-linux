-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

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
