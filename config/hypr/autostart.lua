-- Extra autostart processes.
o.launch_on_start("solaar --window=hide")

-- Mirror the useful application startup set from the desktop.
-- Ferdium is intentionally excluded on this laptop.
-- Stagger Chromium web apps so its single-profile startup does not discard
-- simultaneous --app requests during login.
local function launch_webapp_after(delay_seconds, url)
  o.exec_on_start("sleep " .. delay_seconds .. " && " .. o.launch_webapp(url))
end

o.launch_on_start("chatgpt")
launch_webapp_after(3, "https://app.marshallsystems.io/")
launch_webapp_after(6, "https://calendar.google.com/calendar/u/1/r?pli=1")
launch_webapp_after(9, "https://music.youtube.com/")
