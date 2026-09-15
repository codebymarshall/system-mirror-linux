# System Mirror Linux

This repository is the complete portable layer for reproducing Jonathan's user environment on a fresh Omarchy installation. It deliberately builds on Omarchy rather than replacing its installer, package repositories, hardware detection, or `/usr/share/omarchy` defaults.

The recorded baseline was audited on Omarchy 4.0.3. The setup is desired-state and rolling-release friendly: package names and tool channels are pinned where useful, but Arch package versions are resolved from the currently configured Omarchy repositories.

## New-machine setup

1. Install Omarchy normally and complete its first login.
2. Connect the Logitech Bolt receiver, or pair the MX Keys S and MX Master 3S through Bluetooth. Wake both devices.
3. Clone this repository anywhere under your user account:

   ```bash
   git clone https://github.com/codebymarshall/system-mirror-linux.git
   cd system-mirror-linux
   ```

4. Run the bootstrap as your desktop user—never with `sudo`:

   ```bash
   ./bootstrap.sh
   ```

5. Follow the printed GitHub authentication step if needed, then verify:

   ```bash
   ./doctor.sh
   ```

Bootstrap is idempotent and safe to rerun. It installs missing packages, copies managed files with one `.bak` generation, configures the Logitech devices, enables Voxtype, restores Omarchy defaults and theme selections, installs Mise tools, installs the saved AI skills and global host instructions, and performs the health check.

Package restoration uses `packages/official.txt` and `packages/aur.txt`. Bootstrap passes those manifests to `omarchy pkg add` and `omarchy pkg aur add`, so packages already supplied by Omarchy are skipped and only missing packages are installed. Add future user-installed packages to the matching manifest to include them on the next machine.

## Commands

```bash
./bootstrap.sh                 # Packages + config + tools + defaults + doctor
./apply.sh                     # Reapply managed files and runtime settings
./doctor.sh                    # Read-only health report
./apply.sh --no-runtime        # Copy files without touching the current session
./apply.sh --target-home /tmp/test-home --no-runtime
python3 scripts/skills.py verify
python3 scripts/skills.py install --agent both
python3 scripts/skills.py install-instructions
```

## Managed state

- `config/hypr`: bindings, workspaces, window placement, monitor defaults, autostart, night-light, and screen-sharing portal configuration.
- `config/omarchy`: shell layout and widgets, the named/occupied workspace widget, the Movement Breaks countdown and alerts, the About and screensaver branding, and the custom Masseffect palette, preview, and Wallhaven background.
- `config/plymouth`: the Marshall Systems logo used by the boot splash.
- `plugins/omarchy.tsv`: trusted third-party shell plugin sources pinned to the versions used by the saved bar layout.
- `config/solaar` and `settings.env`: the captured MX Master 3S and MX Keys S settings, gestures, and physical device IDs. Host/pairing slots are deliberately not replayed.
- `config/foot`: terminal sizing, clipboard keys, and Shift+Enter behavior.
- `config/mise`: Codex CLI, .NET, GitHub CLI, and Node tool versions.
- `config/git`: an included aliases/workflow/identity file that preserves machine-local credential helpers.
- `config/voxtype` and `config/systemd`: dictation settings and daemon.
- `config/Cursor`: the current editor theme preference. Cursor intentionally has no dedicated Hyprland keybinding.
- `bin`: the MX-aware keybinding menu, repository-aware LazyGit launcher, and occupied-workspace cycler.
- `packages`: additions to a stock Omarchy installation.
- `ai-skills`, `scripts/skills.py`, and `tests/test_skills.py`: the saved skill collection, portable installer, global host instructions, and installer tests.

## Intentionally not copied

The following require per-machine or per-account decisions and are not safe to put in Git:

- Disk partitioning, encryption keys, firmware, CPU microcode, GPU drivers, and monitor-specific modes. Omarchy detects these during installation.
- GitHub tokens, SSH/private keys, Bitwarden data, browser cookies/profiles, Codex credentials, and application logins.
- Bluetooth pairing records. Pair through the operating system; the same physical Logitech unit IDs in `settings.env` work over Bluetooth or the Bolt receiver.
- Application caches, downloaded AI models, clipboard history, notification history, and transient Omarchy state.

After bootstrap, sign into the applications you use. For GitHub, run:

```bash
gh auth login
gh auth setup-git
```

If either Logitech device was asleep during bootstrap, wake it and rerun `./apply.sh`, followed by `./doctor.sh`.

## Global agent setup

The [skills collection](ai-skills/README.md), installer, global host instructions, and host research live in this repository. Bootstrap installs them automatically. To reinstall them without running the rest of bootstrap:

```bash
python3 scripts/skills.py install --agent both
python3 scripts/skills.py install-instructions
```

The first command installs the personal skills for Codex and Claude Code. The second installs the standing writing policy and automatic skill-routing instructions for every supported agent host. Re-run both commands after this repository changes.
