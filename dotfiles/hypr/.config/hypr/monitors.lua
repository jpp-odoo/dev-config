-- List current monitors and supported modes: hyprctl monitors all

-- ThinkPad L14 Gen 6 (1920x1200), scale 1.25 -> effective 1536x960
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })

-- Dell S2725DC at work (2560x1440), bottom-aligned with laptop
hl.monitor({ output = "desc:Dell Inc. Dell S2725DC", mode = "preferred", position = "1536x-480", scale = 1 })

-- AOC 24P2W1G5 at home (1920x1080), bottom-aligned with laptop
hl.monitor({ output = "desc:AOC 24P2W1G5", mode = "1920x1080@60", position = "1536x-120", scale = 1 })

-- Fallback for any other monitor or laptop-only
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
