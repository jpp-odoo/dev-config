hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "altgr-intl",
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})

-- Scroll nicely in Ghostty (only terminal in use)
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
