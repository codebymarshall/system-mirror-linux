"""Filesystem integration tests. Run on Windows and Linux without extra packages."""
import argparse
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("skills", Path(__file__).resolve().parents[1] / "scripts/skills.py")
skills = importlib.util.module_from_spec(spec)
spec.loader.exec_module(skills)


class SkillTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.original = skills.LIBRARY
        skills.LIBRARY = self.root / "repo" / "ai-skills"
        self.addCleanup(setattr, skills, "LIBRARY", self.original)
        skills.LIBRARY.mkdir(parents=True)
        (skills.LIBRARY / "GLOBAL-INSTRUCTIONS.md").write_text(
            "# Global agent instructions\n\nApply the standing policy.\n", encoding="utf-8"
        )
        self.source_home = self.root / "source user"
        self.skill = self.source_home / ".agents/skills/example"
        self.skill.mkdir(parents=True)
        (self.skill / "SKILL.md").write_text("---\nname: example\ndescription: Example skill\n---\nUse it.\n", encoding="utf-8")
        (self.skill / "assets").mkdir()
        (self.skill / "assets/data.bin").write_bytes(bytes(range(256)))
        (self.skill / "references").mkdir()
        (self.skill / "references/guide.md").write_text("Reference", encoding="utf-8")
        self.home = self.root / "target user"
        self.args = argparse.Namespace(home=self.home, agent="both", dest=None, skill=None, dry_run=False, replace=False)
        self.instruction_args = argparse.Namespace(
            home=self.home, host=None, dry_run=False, replace=False
        )
        self.quiet(skills.capture, argparse.Namespace(home=self.source_home, dry_run=False, replace=False))

    def quiet(self, function, *args):
        with redirect_stdout(io.StringIO()):
            return function(*args)

    def test_install_both_and_rerun_preserves_bytes_and_mtime(self):
        self.quiet(skills.install, self.args)
        for folder in [".agents", ".claude"]:
            target = self.home / folder / "skills/example"
            self.assertEqual(skills.files(self.skill), skills.files(target))
        entry = self.home / ".agents/skills/example/SKILL.md"
        before = entry.stat().st_mtime_ns
        self.quiet(skills.install, self.args)
        self.assertEqual(before, entry.stat().st_mtime_ns)

    def test_windows_bash_template_installs_with_linux_line_endings(self):
        (self.skill / "template.sh").write_bytes(b"#!/usr/bin/env bash\r\necho hello\r\n")
        self.quiet(skills.capture, argparse.Namespace(home=self.source_home, dry_run=False, replace=True))
        self.quiet(skills.install, self.args)
        dest = self.home / ".agents/skills/example/template.sh"
        self.assertEqual(dest.read_bytes(), b"#!/usr/bin/env bash\necho hello\n")
        before = dest.stat().st_mtime_ns
        self.quiet(skills.install, self.args)
        self.assertEqual(before, dest.stat().st_mtime_ns)

    def test_dry_run_makes_no_home(self):
        self.args.dry_run = True
        self.quiet(skills.install, self.args)
        self.assertFalse(self.home.exists())

    def test_later_conflict_blocks_all_writes(self):
        target = self.home / ".claude/skills/example"
        target.mkdir(parents=True)
        (target / "local.txt").write_text("keep me")
        with self.assertRaisesRegex(ValueError, "Conflict"):
            self.quiet(skills.install, self.args)
        self.assertFalse((self.home / ".agents").exists())
        self.assertEqual((target / "local.txt").read_text(), "keep me")

    def test_replace_retains_backup_and_unrelated_skill(self):
        self.quiet(skills.install, self.args)
        target = self.home / ".agents/skills/example"
        (target / "local.txt").write_text("keep me")
        unrelated = self.home / ".agents/skills/unrelated"
        unrelated.mkdir()
        (unrelated / "file").write_text("untouched")
        self.args.replace = True
        self.quiet(skills.install, self.args)
        backups = list((self.home / ".agents/system-mirror-skill-backups").glob("*/local.txt"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "keep me")
        self.assertFalse((target / "local.txt").exists())
        self.assertEqual((unrelated / "file").read_text(), "untouched")

    def test_custom_destination_and_selection(self):
        self.args.agent = None
        self.args.dest = self.root / "custom skills"
        self.args.skill = ["example"]
        self.quiet(skills.install, self.args)
        self.assertTrue((self.args.dest / "example/SKILL.md").is_file())

    def test_tampered_snapshot_blocks_install(self):
        (skills.LIBRARY / "library/example/SKILL.md").write_text("tampered")
        with self.assertRaisesRegex(ValueError, "Snapshot differs"):
            self.quiet(skills.install, self.args)
        self.assertFalse(self.home.exists())

    def test_unknown_skill_blocks_install(self):
        self.args.skill = ["absent"]
        with self.assertRaisesRegex(ValueError, "Unknown"):
            self.quiet(skills.install, self.args)
        self.assertFalse(self.home.exists())

    def test_archive_not_installed(self):
        plugin = self.source_home / ".codex/plugins/cache/vendor/pkg/1/skills/host-only"
        plugin.mkdir(parents=True)
        (plugin / "SKILL.md").write_text("Needs a plugin tool")
        self.quiet(skills.capture, argparse.Namespace(home=self.source_home, dry_run=False, replace=False))
        self.quiet(skills.install, self.args)
        self.assertFalse((self.home / ".agents/skills/host-only").exists())
        self.assertTrue((skills.LIBRARY / "archive/codex-plugins/vendor/pkg/1/skills/host-only/SKILL.md").exists())

    def test_duplicate_name_conflict_does_not_copy(self):
        duplicate = self.source_home / ".codex/skills/example"
        duplicate.mkdir(parents=True)
        (duplicate / "SKILL.md").write_text("different")
        with self.assertRaisesRegex(ValueError, "share a name"):
            self.quiet(skills.capture, argparse.Namespace(home=self.source_home, dry_run=False, replace=False))

    def test_overlap_rejected(self):
        with self.assertRaisesRegex(ValueError, "overlap"):
            skills.preflight([(self.skill, self.skill / "nested")], replace=True)

    def test_symlink_destination_rejected(self):
        link = self.root / "link"
        try:
            link.symlink_to(self.source_home, target_is_directory=True)
        except OSError:
            self.skipTest("Creating symlinks is unavailable on this host")
        self.args.agent = None
        self.args.dest = link
        with self.assertRaisesRegex(ValueError, "Linked"):
            self.quiet(skills.install, self.args)

    def test_removed_source_is_retained_in_snapshot(self):
        self.skill.rename(self.skill.with_name("renamed"))
        # Another source still exists. The old saved skill is retained.
        renamed = self.source_home / ".agents/skills/renamed/SKILL.md"
        renamed.write_text("---\nname: renamed\ndescription: Renamed\n---\nUse it.\n")
        self.quiet(skills.capture, argparse.Namespace(home=self.source_home, dry_run=False, replace=False))
        self.quiet(skills.verify, None)
        self.assertEqual(len(skills.personal_skills()), 2)

    def test_global_instructions_install_for_every_host(self):
        self.quiet(skills.install_instructions, self.instruction_args)
        source = (skills.LIBRARY / "GLOBAL-INSTRUCTIONS.md").read_bytes()
        for host, relative in skills.INSTRUCTION_TARGETS.items():
            target = self.home / relative
            if host == "cursor":
                self.assertTrue((target / ".cursor-plugin/plugin.json").is_file())
                rule = (target / "rules/global-instructions.mdc").read_bytes()
                self.assertIn(b"alwaysApply: true", rule)
                self.assertTrue(rule.endswith(source))
            elif host == "grok":
                self.assertIn(b"GLOBAL-INSTRUCTIONS.md", target.read_bytes())
            else:
                self.assertEqual(source, target.read_bytes())

    def test_global_instructions_rerun_preserves_mtime(self):
        self.instruction_args.host = ["codex"]
        self.quiet(skills.install_instructions, self.instruction_args)
        target = self.home / ".codex/AGENTS.md"
        before = target.stat().st_mtime_ns
        self.quiet(skills.install_instructions, self.instruction_args)
        self.assertEqual(before, target.stat().st_mtime_ns)

    def test_global_instruction_selection_also_installs_generic_source(self):
        self.instruction_args.host = ["claude"]
        self.quiet(skills.install_instructions, self.instruction_args)
        self.assertTrue((self.home / ".claude/CLAUDE.md").is_file())
        self.assertTrue((self.home / ".config/ai-agent/GLOBAL-INSTRUCTIONS.md").is_file())
        self.assertFalse((self.home / ".codex/AGENTS.md").exists())

    def test_global_instruction_conflict_blocks_all_writes(self):
        conflict = self.home / ".claude/CLAUDE.md"
        conflict.parent.mkdir(parents=True)
        conflict.write_text("keep me", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Conflict"):
            self.quiet(skills.install_instructions, self.instruction_args)
        self.assertEqual("keep me", conflict.read_text(encoding="utf-8"))
        self.assertFalse((self.home / ".codex/AGENTS.md").exists())

    def test_global_instruction_replace_keeps_backup(self):
        target = self.home / ".codex/AGENTS.md"
        target.parent.mkdir(parents=True)
        target.write_text("keep me", encoding="utf-8")
        self.instruction_args.host = ["codex"]
        self.instruction_args.replace = True
        self.quiet(skills.install_instructions, self.instruction_args)
        backups = list((self.home / ".system-mirror-instruction-backups").glob("codex-*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual("keep me", backups[0].read_text(encoding="utf-8"))
        self.assertEqual(
            (skills.LIBRARY / "GLOBAL-INSTRUCTIONS.md").read_bytes(), target.read_bytes()
        )

    def test_global_instruction_dry_run_writes_nothing(self):
        self.instruction_args.dry_run = True
        self.quiet(skills.install_instructions, self.instruction_args)
        self.assertFalse(self.home.exists())


if __name__ == "__main__":
    unittest.main()
