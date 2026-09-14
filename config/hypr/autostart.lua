-- Extra autostart processes.
o.launch_on_start("solaar --window=hide")

-- Mirror the useful application startup set from the desktop.
-- Ferdium is intentionally excluded on this laptop.
o.exec_on_start(o.launch_webapp("https://music.youtube.com/"))
o.launch_on_start("codex-desktop")
o.exec_on_start(o.launch_webapp("https://calendar.google.com/calendar/u/1/r?pli=1"))
o.exec_on_start(o.launch_webapp("https://app.marshallsystems.io/"))
