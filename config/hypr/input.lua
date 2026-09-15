-- Personal input overrides can be added here. Logitech MX behavior that Solaar
-- owns lives in ~/.config/solaar/rules.yaml instead of Hyprland's input block.

-- Invert two-finger touchpad scrolling without changing external mouse wheels.
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
    },
  },
})
