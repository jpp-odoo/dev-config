-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Reload hyprpm-managed plugins (e.g. scrolloverview) on every login.
o.exec_on_start("hyprpm reload -n")
