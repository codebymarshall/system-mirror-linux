-- Application placement translated from SystemMirror's GlazeWM config.
-- Static workspace rules use initial classes, as required by Hyprland 0.56.

-- Named workspaces are deliberately not persistent. This lets e±1 navigation
-- skip empty workspaces while Super+1…7 can still create them on demand.

-- Home (ChatGPT and Google Calendar)
o.window("^(ChatGPT|com\\.openai\\.[Cc]hat[Gg][Pp][Tt]|.+-chatgpt\\.com__.*|.+-calendar\\.google\\.com__.*)$", {
  workspace = "name:Home silent",
})

-- Work (Marshall Systems web app)
o.window("^.+-app\\.marshallsystems\\.io__.*$", { workspace = "name:Work silent" })

-- Dev (development tools)
o.window("^(Code|code|code-oss|VSCodium|[Cc]ursor|studio64|jetbrains-.*|idea64|sublime_text)$", {
  workspace = "name:Dev silent",
})

-- Office (office and productivity)
o.window("^(NordVPN|nordvpn|libreoffice.*|soffice|Microsoft Teams.*|teams-for-linux|Skype|skypeforlinux)$", {
  workspace = "name:Office silent",
})

-- Gaming launchers and Proton games retain the existing workspace placement.
-- No extra float/fullscreen/title rules are imported from Windows.
o.window("^(steam|steam_app_.*|steam_app_battlenet|Heroic|heroic|com\\.heroicgameslauncher\\.hgl|lutris|net\\.lutris\\.Lutris|Bottles|com\\.usebottles\\.bottles|EADesktop|EpicGamesLauncher|UbisoftConnect|upc|voobly)$", {
  workspace = "name:Gaming silent",
})

-- Media
o.window("^(qBittorrent|qbittorrent|vlc|mpv|stremio|org\\.gnome\\.Loupe|.+-music\\.youtube\\.com__.*)$", {
  workspace = "name:Media silent",
})

-- Comms
o.window("^(Discord|discord|Ferdium|ferdium|WhatsApp|whatsapp-for-linux|.+-discord\\.com__.*|.+-web\\.whatsapp\\.com__.*)$", {
  workspace = "name:Comms silent",
})

-- Linux counterparts of the source config's floating utility windows.
o.window("^(wezterm-gui|org\\.gnome\\.Nautilus|zen|Zen|FileBot|filebot|org\\.gnome\\.SystemMonitor|org\\.kde\\.systemmonitor)$", {
  float = true,
  center = true,
})
