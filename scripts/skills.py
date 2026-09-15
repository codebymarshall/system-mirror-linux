"""Back up and install skills and host instructions. Python 3.10+, no packages."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sys
import uuid

REPO = Path(__file__).resolve().parents[1]
LIBRARY = REPO / "ai-skills"
SKIP = {".git", "__pycache__", "node_modules", ".venv", "venv", ".DS_Store"}
INSTRUCTION_TARGETS = {
    "codex": ".codex/AGENTS.md",
    "claude": ".claude/CLAUDE.md",
    "gemini": ".gemini/GEMINI.md",
    "opencode": ".config/opencode/AGENTS.md",
    "copilot": ".copilot/copilot-instructions.md",
    "crush": ".config/crush/CRUSH.md",
    "grok": ".grok/rules/system-mirror-global.md",
    "cursor": ".cursor/plugins/local/system-mirror-global-instructions",
    "generic": ".config/ai-agent/GLOBAL-INSTRUCTIONS.md",
}


def linked(path):
    # FILE_ATTRIBUTE_REPARSE_POINT also catches junctions on Python 3.10/3.11.
    try:
        reparse = bool(getattr(path.lstat(), "st_file_attributes", 0) & 0x400)
    except FileNotFoundError:
        reparse = False
    return path.is_symlink() or reparse


def regular_path(path):
    for item in [path, *path.parents]:
        if linked(item):
            raise ValueError(f"Linked path requires manual handling: {item}")


def files(root, normalize_shell=False):
    regular_path(root)
    if not root.is_dir():
        raise ValueError(f"Not a directory: {root}")
    result = {}
    for parent, dirs, names in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in SKIP)
        for name in dirs + sorted(names):
            if name in SKIP or name.endswith(".pyc"):
                continue
            path = Path(parent) / name
            if linked(path):
                raise ValueError(f"Linked content requires manual handling: {path}")
            if path.is_file():
                if name == ".env" or name.startswith(".env.") and name not in {".env.example", ".env.sample"}:
                    raise ValueError(f"Review environment file before export: {path}")
                data = path.read_bytes()
                if normalize_shell and path.suffix == ".sh":
                    data = data.replace(b"\r\n", b"\n")
                result[path.relative_to(root).as_posix()] = hashlib.sha256(data).hexdigest()
    return result


def same(source, target, normalize_shell=False):
    return target.is_dir() and files(source, normalize_shell) == files(target)


def preflight(pairs, replace=False, normalize_shell=False):
    destinations = set()
    for source, target in pairs:
        regular_path(source)
        regular_path(target)
        src, dst = source.resolve(), target.resolve()
        if src == dst or src in dst.parents or dst in src.parents:
            raise ValueError(f"Source and destination overlap: {source} / {target}")
        key = str(dst).casefold()
        if key in destinations:
            raise ValueError(f"Duplicate destination: {target}")
        destinations.add(key)
        files(source)
        if target.exists() and not same(source, target, normalize_shell) and not replace:
            raise ValueError(f"Conflict: {target}. Review it, then use --replace to back it up and replace it.")


def copy_skill(source, target, backup_root, dry_run=False, normalize_shell=False):
    if same(source, target, normalize_shell):
        print(f"UNCHANGED {target}")
        return
    print(f"{'REPLACE' if target.exists() else 'COPY'} {target}")
    if dry_run:
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    # Stage on the same volume. No existing destination is deleted.
    stage = target.parent / (".skill-stage-" + uuid.uuid4().hex)
    stage.mkdir()
    for relative in files(source):
        dest = stage / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source / relative, dest)
        if normalize_shell and dest.suffix == ".sh":
            dest.write_bytes(dest.read_bytes().replace(b"\r\n", b"\n"))
    if files(stage) != files(source, normalize_shell):
        raise ValueError(f"Copy verification failed: {stage}")
    backup = None
    if target.exists():
        regular_path(backup_root)
        backup_root.mkdir(parents=True, exist_ok=True)
        backup = backup_root / (target.name + "-" + uuid.uuid4().hex)
        target.rename(backup)
        print(f"BACKUP {backup}")
    try:
        stage.rename(target)
    except OSError:
        if backup is not None:
            backup.rename(target)
        raise


def instruction_payload(host):
    source = LIBRARY / "GLOBAL-INSTRUCTIONS.md"
    regular_path(source)
    body = source.read_bytes()
    if host == "cursor":
        manifest = {
            "name": "system-mirror-global-instructions",
            "version": "1.0.0",
            "description": "Global writing policy and task-skill routing from System Mirror",
            "author": {"name": "System Mirror"},
            "rules": "./rules/",
        }
        rule = (b"---\ndescription: Global writing policy and task-skill routing\n"
                b"alwaysApply: true\n---\n\n" + body)
        return {
            ".cursor-plugin/plugin.json":
                (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode("utf-8"),
            "rules/global-instructions.mdc": rule,
        }
    if host == "grok":
        return {".": (
            "# System Mirror global instructions\n\n"
            "Apply `~/.config/ai-agent/GLOBAL-INSTRUCTIONS.md` to every interaction. "
            "If the same policy is already present through Grok's Claude compatibility, "
            "do not load it twice. Otherwise, read the complete file before substantive work.\n"
        ).encode("utf-8")}
    return {".": body}


def payload_hashes(payload):
    return {name: hashlib.sha256(data).hexdigest() for name, data in payload.items()}


def same_instruction(payload, target):
    if set(payload) == {"."}:
        return target.is_file() and target.read_bytes() == payload["."]
    return target.is_dir() and files(target) == payload_hashes(payload)


def preflight_instructions(entries, replace=False):
    destinations = set()
    for _, target, payload in entries:
        regular_path(target)
        key = str(target.absolute()).casefold()
        if key in destinations:
            raise ValueError(f"Duplicate destination: {target}")
        destinations.add(key)
        if target.exists() and not same_instruction(payload, target) and not replace:
            raise ValueError(
                f"Conflict: {target}. Review it, then use --replace to back it up and replace it."
            )


def copy_instruction(host, payload, target, backup_root, dry_run=False):
    if same_instruction(payload, target):
        print(f"UNCHANGED {host}: {target}")
        return
    print(f"{'REPLACE' if target.exists() else 'COPY'} {host}: {target}")
    if dry_run:
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    is_file = set(payload) == {"."}
    stage = target.parent / (".instruction-stage-" + uuid.uuid4().hex)
    if is_file:
        stage.write_bytes(payload["."])
        if stage.read_bytes() != payload["."]:
            raise ValueError(f"Copy verification failed: {stage}")
    else:
        stage.mkdir()
        for relative, data in payload.items():
            destination = stage / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(data)
        if files(stage) != payload_hashes(payload):
            raise ValueError(f"Copy verification failed: {stage}")
    backup = None
    if target.exists():
        regular_path(backup_root)
        backup_root.mkdir(parents=True, exist_ok=True)
        backup = backup_root / (host + "-" + uuid.uuid4().hex)
        target.rename(backup)
        print(f"BACKUP {backup}")
    try:
        stage.rename(target)
    except OSError:
        if backup is not None:
            backup.rename(target)
        raise


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + ".tmp")
    temp.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    temp.replace(path)


def write_catalog(entries):
    lines = ["# Skill catalog", "", "Read [USAGE.md](USAGE.md) when using these skills on another host.",
             "", "## Personal skills", "", "| Skill | Description |", "| --- | --- |"]
    unique = {entry["path"]: entry for entry in entries}
    for path, entry in sorted(unique.items()):
        if entry["kind"] != "personal":
            continue
        skill = LIBRARY / path
        body = (skill / "SKILL.md").read_text(encoding="utf-8-sig")
        match = re.search(r"^description: *(.*)$", body, re.M)
        description = match[1].strip().strip('"') if match else "Read the skill."
        description = description.replace("|", "&#124;").replace("\\", "")
        lines.append(f"| [{skill.name}]({path}/SKILL.md) | {description} |")
    lines += ["", "## System and cached plugin skills", "",
              "These are preserved copies. Their original tool and runtime dependencies are not installed by this repo.", ""]
    for path, entry in sorted(unique.items()):
        if entry["kind"] != "personal":
            lines.append(f"- [{path.removeprefix('archive/')}]({path}/SKILL.md)")
    (LIBRARY / "CATALOG.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def capture(args):
    home = args.home.expanduser().resolve()
    roots = [
        ("agents", home / ".agents/skills", True),
        ("codex", home / ".codex/skills", True),
        ("claude", home / ".claude/skills", True),
        ("codex-plugins", home / ".codex/plugins/cache", False),
        ("claude-plugins", home / ".claude/plugins/cache", False),
    ]
    entries, pairs, seen = [], [], {}
    for label, root, personal in roots:
        if not root.exists():
            continue
        regular_path(root)
        for entry in sorted(root.rglob("SKILL.md")):
            if any(part in SKIP for part in entry.relative_to(root).parts):
                continue
            source = entry.parent
            relative = source.relative_to(root)
            is_personal = personal and ".system" not in relative.parts
            digest = files(source)
            if is_personal:
                target = LIBRARY / "library" / source.name
                key = source.name.casefold()
                if key in seen:
                    if seen[key] != digest:
                        raise ValueError(f"Different personal skills share a name: {source.name}")
                else:
                    pairs.append((source, target))
                    seen[key] = digest
            else:
                target = LIBRARY / "archive" / label / relative
                pairs.append((source, target))
            entries.append({"source": "~/" + source.relative_to(home).as_posix(),
                            "path": target.relative_to(LIBRARY).as_posix(),
                            "kind": "personal" if is_personal else "host-dependent", "files": digest})
    if not entries:
        raise ValueError("No skills found. Check --home.")
    preflight(pairs, args.replace)
    for source, target in pairs:
        copy_skill(source, target, LIBRARY / ".backups", args.dry_run)
    if not args.dry_run:
        previous = LIBRARY / "manifest.json"
        old = json.loads(previous.read_text(encoding="utf-8"))["skills"] if previous.exists() else []
        sources = {item["source"] for item in entries}
        paths = {item["path"] for item in entries}
        retained = [item for item in old if item["source"] not in sources and item["path"] not in paths]
        write_json(previous, {"format": 1, "captured_at": datetime.now(timezone.utc).isoformat(),
                              "excluded": sorted(SKIP | {"*.pyc"}), "skills": entries + retained})
        write_catalog(entries + retained)
    print(f"Captured {len(entries)} source skill folders; {len(seen)} personal skills.")


def personal_skills():
    result = sorted(p.parent for p in (LIBRARY / "library").glob("*/SKILL.md"))
    if not result:
        raise ValueError("No personal skills found.")
    for skill in result:
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", skill.name) or len(skill.name) > 64:
            raise ValueError(f"Invalid skill folder name: {skill.name}")
        text = (skill / "SKILL.md").read_text(encoding="utf-8-sig")
        parts = text.split("---", 2)
        if len(parts) < 3 or parts[0].strip():
            raise ValueError(f"Missing frontmatter: {skill}")
        header = parts[1]
        name = re.search(r"^name:\s*([^\r\n]+)", header, re.M)
        if not name or name[1].strip().strip("\"'") != skill.name:
            raise ValueError(f"Name does not match folder: {skill}")
        if not re.search(r"^description:\s*\S", header, re.M):
            raise ValueError(f"Missing description: {skill}")
    return result


def verify(args):
    manifest = json.loads((LIBRARY / "manifest.json").read_text(encoding="utf-8"))
    tracked = set()
    for entry in manifest["skills"]:
        path = (LIBRARY / entry["path"]).resolve()
        if LIBRARY.resolve() not in path.parents:
            raise ValueError(f"Manifest path escapes library: {entry['path']}")
        if files(path) != entry["files"]:
            raise ValueError(f"Snapshot differs from manifest: {entry['path']}")
        tracked.add(path)
    discovered = {p.parent.resolve() for root in [LIBRARY / "library", LIBRARY / "archive"]
                  for p in root.rglob("SKILL.md")}
    if discovered != tracked:
        raise ValueError("Manifest does not cover every saved skill folder.")
    count = len(personal_skills())
    print(f"Verified {len(tracked)} saved skill folders, including {count} personal skills.")


def install(args):
    verify(args)
    selected = personal_skills()
    if args.skill:
        requested = set(args.skill)
        missing = requested - {p.name for p in selected}
        if missing:
            raise ValueError("Unknown personal skills: " + ", ".join(sorted(missing)))
        selected = [p for p in selected if p.name in requested]
    if args.dest and args.agent:
        raise ValueError("Use --dest or --agent, not both.")
    home = args.home.expanduser().absolute()
    folders = {"codex": [".agents/skills"], "claude": [".claude/skills"],
               "both": [".agents/skills", ".claude/skills"]}
    roots = [args.dest.expanduser().absolute()] if args.dest else [
        home / folder for folder in folders[args.agent or "both"]]
    pairs = [(source, root / source.name) for root in roots for source in selected]
    preflight(pairs, args.replace, normalize_shell=True)
    for source, target in pairs:
        copy_skill(source, target, target.parent.parent / "system-mirror-skill-backups",
                   args.dry_run, normalize_shell=True)
    print(f"{'Would install' if args.dry_run else 'Installed'} {len(selected)} skills to {len(roots)} global skill folder(s).")


def install_instructions(args):
    source = LIBRARY / "GLOBAL-INSTRUCTIONS.md"
    if not source.is_file():
        raise ValueError(f"Missing global instructions: {source}")
    hosts = list(INSTRUCTION_TARGETS) if not args.host or "all" in args.host else list(dict.fromkeys(args.host))
    # Grok's native rule points here so it does not duplicate Claude-compatible instructions.
    if "generic" not in hosts:
        hosts.append("generic")
    home = args.home.expanduser().absolute()
    entries = [
        (host, home / INSTRUCTION_TARGETS[host], instruction_payload(host))
        for host in hosts
    ]
    preflight_instructions(entries, args.replace)
    backup_root = home / ".system-mirror-instruction-backups"
    for host, target, payload in entries:
        copy_instruction(host, payload, target, backup_root, args.dry_run)
    action = "Would install" if args.dry_run else "Installed"
    print(f"{action} global instructions for {len(hosts)} host target(s).")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    for command in ("capture", "install"):
        p = sub.add_parser(command)
        p.add_argument("--home", type=Path, default=Path.home(), help="Source or destination user home")
        p.add_argument("--dry-run", action="store_true", help="Print proposed copies without writing")
        p.add_argument("--replace", action="store_true", help="Back up conflicting folders before replacing them")
        if command == "install":
            p.add_argument("--agent", choices=["codex", "claude", "both"])
            p.add_argument("--dest", type=Path, help="Custom global skills directory for another agent")
            p.add_argument("--skill", action="append", help="Install only this personal skill; repeatable")
    p = sub.add_parser("install-instructions")
    p.add_argument("--home", type=Path, default=Path.home(), help="Destination user home")
    p.add_argument("--host", action="append", choices=[*INSTRUCTION_TARGETS, "all"],
                   help="Install for this host; repeatable. Defaults to all.")
    p.add_argument("--dry-run", action="store_true", help="Print proposed writes without changing files")
    p.add_argument("--replace", action="store_true", help="Back up conflicting targets before replacing them")
    sub.add_parser("verify")
    args = parser.parse_args()
    try:
        {"capture": capture, "install": install, "install-instructions": install_instructions,
         "verify": verify}[args.command](args)
    except (OSError, ValueError, KeyError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
