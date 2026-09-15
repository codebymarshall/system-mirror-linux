# Shared AI skills

This collection saves the skill files from this Windows user profile for use on other machines. It contains 22 personal skills and 66 system or cached plugin skill folders. References, scripts, templates, assets, and license files inside each skill folder are included. The original file contents are preserved.

The installer uses Python 3.10 or newer with no third-party packages. It works independently of the Windows setup and scheduled tasks in this repo.

## Install on another machine

Clone this repo, open a terminal in the clone, then run:

Linux:

```sh
python3 scripts/skills.py verify
python3 scripts/skills.py install --agent both
```

Windows:

```powershell
python scripts/skills.py verify
python scripts/skills.py install --agent both
```

Use your Python 3 executable if it has a different name. No administrator privileges or symbolic links are required. Use your normal user account, not sudo. Global means all projects for that user.

| Destination | Global skill directory |
| --- | --- |
| Codex, using `--agent codex` | `~/.agents/skills/<name>/` |
| Claude Code, using `--agent claude` | `~/.claude/skills/<name>/` |
| Both, the default | Both directories above |
| Another agent, using `--dest PATH` | The directory you provide |

The home directory comes from the machine running the installer. It is not tied to a Windows username or a particular clone location. WSL and Windows have separate user homes; run the installer in each environment where you run agents.

Add `--dry-run` to inspect the operation. Repeat `--skill NAME` to install selected personal skills. Some skills call others, so the full personal set is the default.

```sh
python3 scripts/skills.py install --agent codex --dry-run
python3 scripts/skills.py install --dest "$HOME/my-agent/skills" --skill tdd
```

That custom destination is an example, not a documented Grok configuration path. Configure your agent application to discover the folder.

## Updates and existing skills

Installed skills are copies. The installer converts Bash scripts to LF line endings so Windows-authored templates run on Linux. Saved originals and their manifest hashes remain unchanged. After pulling repo updates, run the installer again. Identical copies are left untouched. If any selected destination differs, the installer stops before copying anything.

To replace conflicts after reviewing them:

```sh
python3 scripts/skills.py install --agent both --replace
```

Each changed skill folder is moved into a uniquely named backup under the agent configuration directory's `system-mirror-skill-backups/` folder before replacement. Backups are outside the discovery folder. Unrelated skills are left alone. The script prints every backup path. To roll back, move the replacement aside and restore that backup to its original skill directory.

Linked destinations require manual handling. The installer will not follow them or overwrite their targets. The skill installer does not edit global instruction files, install provider runtimes, or configure credentials; use the separate `install-instructions` command for instruction files. A mid-run filesystem failure can leave earlier skills installed; each replacement retains its backup.

Restart the agent if new skills do not appear. In Codex, mention a skill using `$tdd`; in Claude Code, use `/tdd`. Some imported skills deliberately require explicit invocation.

## Install global host instructions

The skill folders make workflows available. The global host instructions enforce the standing writing policy and tell each agent when it must load a task-specific skill.

Preview and install them for the current user:

```sh
python3 scripts/skills.py install-instructions --dry-run
python3 scripts/skills.py install-instructions
```

The default installs the same managed policy for Codex, Claude Code, Gemini CLI, OpenCode, GitHub Copilot CLI, Crush, Grok Build, Cursor, and a generic local-client copy. Select hosts with repeated `--host NAME` options. The installer also writes the generic copy because Grok's small native adapter uses it when Claude compatibility has not already supplied the policy.

Cursor receives a local plugin with an always-applied rule. Restart Cursor or run `Developer: Reload Window` after installation. ChatGPT Custom Instructions and Cursor's account-backed User Rules are application settings and cannot be installed as ordinary files.

Existing differing targets stop the entire operation. Review them, then pass `--replace` to move each old target into `~/.system-mirror-instruction-backups/` before installing the managed copy. Re-running the command leaves identical files untouched.

The source of truth is [GLOBAL-INSTRUCTIONS.md](GLOBAL-INSTRUCTIONS.md). The host-path research and limitations are recorded in [docs/global-host-instructions-research.md](docs/global-host-instructions-research.md).

## Using the same skills with different models

A skill is a folder of instructions and optional resources. Automatic discovery belongs to the application running the model. A Grok, Claude, or Codex model cannot discover local files unless its host supplies that access.

For an agent without native skill discovery, give it the path to [CATALOG.md](CATALOG.md) and [USAGE.md](USAGE.md), then ask it to read the relevant skill's `SKILL.md`. You can add this pointer to that agent's global instructions:

> My reusable skill library is at <absolute clone path>/ai-skills. When a task matches a skill in CATALOG.md, read USAGE.md and that skill's SKILL.md, then follow its referenced resources as needed.

Replace the placeholder with the local clone path. This is a manual integration point, not a promise that every chat app reads files or supports tools.

Some personal skills request a Skill tool, background agents, GitHub or GitLab CLIs, a configured issue tracker, or Bash. [USAGE.md](USAGE.md) explains the host adaptations. The files are portable; those capabilities still need to exist on the destination.

## What is saved

- [library/](library/) contains the 22 personal skills, installed by default.
- [archive/](archive/) preserves 6 Codex system skills and 60 cached plugin skill folders with their source namespace and version paths. Cache presence does not establish that a plugin is currently enabled.
- [manifest.json](manifest.json) records each source path relative to the user home and SHA-256 hashes for every included file.
- [CATALOG.md](CATALOG.md) lists the personal skills and archive locations.

Archive skills may require Codex desktop APIs, MCP tools, authenticated connectors, external supporting files, or bundled runtimes. Reinstall their original plugins on supported hosts to restore those capabilities. Copying a plugin skill folder alone does not install its tools. Both cached Sites versions are preserved.

The capture covers `~/.agents/skills`, `~/.codex/skills`, `~/.claude/skills`, and Codex/Claude plugin caches. It excludes repository-specific skills elsewhere, private memories, conversations, credentials outside the skill folders, and plugin binaries or tool implementations. Existing license files inside the skills are preserved. This backup does not grant a new license to third-party content.

To capture future additions from these locations on a source machine:

```sh
python3 scripts/skills.py capture --dry-run
python3 scripts/skills.py capture
python3 scripts/skills.py verify
```

Capture also refuses differing destinations unless `--replace` is supplied. Capture backups stay in the ignored `ai-skills/.backups/` directory. Skills no longer present on the source machine remain saved. For nonstandard user directories, pass `--home PATH`. Custom `CODEX_HOME` paths outside that home are not discovered automatically.

Edit live personal skills, then capture the changes and review the repo diff. The manifest is a snapshot integrity check, so editing saved files directly requires updating the snapshot deliberately. Preserve upstream sources and versions when making adapted copies.

## Verification

```sh
python3 -m unittest discover -s tests -p test_skills.py -v
python3 scripts/skills.py verify
```

Tests install into temporary user homes. They cover both destinations, assets, repeat installs, dry runs, conflict preflight, backups, unrelated skills, custom destinations, selection, tampering, duplicate names, overlap, symlinks, and archive exclusion. They do not certify every imported workflow or plugin on every agent.

## Documentation sources

Checked during implementation:

- [OpenAI global skill discovery](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code personal skills](https://code.claude.com/docs/en/skills)
- [Agent Skills file format](https://agentskills.io/specification)
