# SystemMirror for Omarchy Linux

This directory is the complete portable layer for reproducing Jonathan's user environment on a fresh Omarchy installation. It deliberately builds on Omarchy rather than replacing its installer, package repositories, hardware detection, or `/usr/share/omarchy` defaults.

The recorded baseline was audited on Omarchy 4.0.3. The setup is desired-state and rolling-release friendly: package names and tool channels are pinned where useful, but Arch package versions are resolved from the currently configured Omarchy repositories.

## New-machine setup

1. Install Omarchy normally and complete its first login.
2. Connect the Logitech Bolt receiver, or pair the MX Keys S and MX Master 3S through Bluetooth. Wake both devices.
3. Clone SystemMirror anywhere under your user account.
4. Run the bootstrap as your desktop user—never with `sudo`:

   ```bash
   ./linux/bootstrap.sh
   ```

5. Follow the printed GitHub authentication step if needed, then verify:

   ```bash
   ./linux/doctor.sh
   ```

Bootstrap is idempotent and safe to rerun. It installs missing packages, copies managed files with one `.bak` generation, configures the Logitech devices, enables Voxtype, restores Omarchy defaults/theme selections, installs Mise tools, and performs the health check.

## Commands

```bash
./linux/bootstrap.sh                 # Packages + config + tools + defaults + doctor
./linux/apply.sh                     # Reapply managed files and runtime settings
./linux/doctor.sh                    # Read-only health report
./linux/apply.sh --no-runtime        # Copy files without touching the current session
./linux/apply.sh --target-home /tmp/test-home --no-runtime
```

## Managed state

- `config/hypr`: bindings, workspaces, window placement, monitor defaults, autostart, night-light, and screen-sharing portal configuration.
- `config/omarchy`: shell layout and the named/occupied workspace widget.
- `config/solaar` and `settings.env`: the captured MX Master 3S and MX Keys S settings, gestures, and physical device IDs. Host/pairing slots are deliberately not replayed.
- `config/foot`: terminal sizing, clipboard keys, and Shift+Enter behavior.
- `config/mise`: Codex CLI, GitHub CLI, and Node tool versions.
- `config/git`: an included aliases/workflow/identity file that preserves machine-local credential helpers.
- `config/voxtype` and `config/systemd`: dictation settings and daemon.
- `config/Cursor`: the current editor theme preference. Cursor intentionally has no dedicated Hyprland keybinding.
- `bin`: the MX-aware keybinding menu, repository-aware LazyGit launcher, and occupied-workspace cycler.
- `packages`: additions to a stock Omarchy installation.

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

If either Logitech device was asleep during bootstrap, wake it and rerun `./linux/apply.sh`, followed by `./linux/doctor.sh`.

## Global AI skills

The shared [skills collection](../ai-skills/README.md) installs separately from Omarchy setup. From the repository root, run `python3 scripts/skills.py install --agent both` to copy personal skills into the current user's Codex and Claude Code directories. Use `--agent codex` for Codex alone. The installer requires Python 3.10 or newer and also works on other Linux distributions.
