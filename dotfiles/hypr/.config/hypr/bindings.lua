-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- SUPER+TAB was "Next workspace"; repurpose it for the niri-like scroll
-- overview (scrolloverview plugin) and move "Next workspace" to PAGE_DOWN.
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Toggle scroll overview", function()
  return hl.plugin.scrolloverview.overview("toggle all")
end)
o.bind("SUPER + PAGE_DOWN", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- 3-finger touchpad swipes move the selection while the scroll overview is open.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
  hl.gesture({
    fingers = 3,
    direction = direction,
    action = function()
      hl.dispatch(hl.plugin.scrolloverview.navigate(direction))
    end,
  })
end
