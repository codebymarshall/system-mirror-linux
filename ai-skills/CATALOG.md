# Skill catalog

Read [USAGE.md](USAGE.md) when using these skills on another host.

## Personal skills

| Skill | Description |
| --- | --- |
| [code-review](library/code-review/SKILL.md) | Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". |
| [codebase-design](library/codebase-design/SKILL.md) | Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary. |
| [diagnosing-bugs](library/diagnosing-bugs/SKILL.md) | Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow. |
| [domain-modeling](library/domain-modeling/SKILL.md) | Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR. |
| [find-skills](library/find-skills/SKILL.md) | Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill. |
| [grill-me](library/grill-me/SKILL.md) | A relentless interview to sharpen a plan or design. |
| [grill-with-docs](library/grill-with-docs/SKILL.md) | A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go. |
| [grilling](library/grilling/SKILL.md) | Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. |
| [handoff](library/handoff/SKILL.md) | Compact the current conversation into a handoff document for another agent to pick up. |
| [implement](library/implement/SKILL.md) | Implement a piece of work based on a spec or set of tickets. |
| [improve-codebase-architecture](library/improve-codebase-architecture/SKILL.md) | Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. |
| [prototype](library/prototype/SKILL.md) | Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like. |
| [research](library/research/SKILL.md) | Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent. |
| [setup-matt-pocock-skills](library/setup-matt-pocock-skills/SKILL.md) | Configure this repo for the engineering skills: set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills. |
| [tdd](library/tdd/SKILL.md) | Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests. |
| [teach](library/teach/SKILL.md) | Teach the user a new skill or concept, within this workspace. |
| [triage](library/triage/SKILL.md) | Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs. |
| [unslop](library/unslop/SKILL.md) | Cut AI tells from any writing. Must always apply. |
| [wait-what](library/wait-what/SKILL.md) | Stop. That last message did not land: re-pitch it. |
| [wayfinder](library/wayfinder/SKILL.md) | Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear. |
| [wizard](library/wizard/SKILL.md) | Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover. Don't invoke this for steps the agent can perform itself. |
| [writing-for-agents](library/writing-for-agents/SKILL.md) | Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md. |

## System and cached plugin skills

These are preserved copies. Their original tool and runtime dependencies are not installed by this repo.

- [codex-plugins/openai-bundled/computer-use/26.908.40834/skills/computer-use](archive/codex-plugins/openai-bundled/computer-use/26.908.40834/skills/computer-use/SKILL.md)
- [codex-plugins/openai-bundled/sites/0.1.70/skills/sites-building](archive/codex-plugins/openai-bundled/sites/0.1.70/skills/sites-building/SKILL.md)
- [codex-plugins/openai-bundled/sites/0.1.70/skills/sites-hosting](archive/codex-plugins/openai-bundled/sites/0.1.70/skills/sites-hosting/SKILL.md)
- [codex-plugins/openai-bundled/visualize/1.0.37/skills/visualize](archive/codex-plugins/openai-bundled/visualize/1.0.37/skills/visualize/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-brand-check](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-brand-check/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-branded-presentation](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-branded-presentation/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-bulk-create](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-bulk-create/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-design-feedback](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-design-feedback/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-edit-design](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-edit-design/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-implement-feedback](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-implement-feedback/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-resize-for-social-media](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-resize-for-social-media/SKILL.md)
- [codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-translate-design](archive/codex-plugins/openai-curated-remote/canva/15.0.0/skills/canva-translate-design/SKILL.md)
- [codex-plugins/openai-curated-remote/deep-research-work/0.1.15/skills/deep-research](archive/codex-plugins/openai-curated-remote/deep-research-work/0.1.15/skills/deep-research/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-code-connect](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-code-connect/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-create-new-file](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-create-new-file/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-design-to-code](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-design-to-code/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-design](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-design/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-diagram](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-diagram/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-library](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-generate-library/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-implement-motion](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-implement-motion/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-swiftui](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-swiftui/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-figjam](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-figjam/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-motion](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-motion/SKILL.md)
- [codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-slides](archive/codex-plugins/openai-curated-remote/figma/2.0.21/skills/figma-use-slides/SKILL.md)
- [codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-docs](archive/codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-docs/SKILL.md)
- [codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-drive](archive/codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-drive/SKILL.md)
- [codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-drive-comments](archive/codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-drive-comments/SKILL.md)
- [codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-sheets](archive/codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-sheets/SKILL.md)
- [codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-slides](archive/codex-plugins/openai-curated-remote/google-drive/0.1.16/skills/google-slides/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-analytics-dashboard](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-analytics-dashboard/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-business-review](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-business-review/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-design-report](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-design-report/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-experiment-analysis](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-experiment-analysis/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-financial-budget](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-financial-budget/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-investment-committee-memo](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-investment-committee-memo/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-legal-memorandum](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-legal-memorandum/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-market-trends-report](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-market-trends-report/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-minimal-letterhead](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-minimal-letterhead/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-operating-calendar](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-operating-calendar/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-operating-review](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-operating-review/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-project-kickoff](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-project-kickoff/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-project-tracker](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-project-tracker/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-sales-pipeline](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-sales-pipeline/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-simple-dark-mode](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-simple-dark-mode/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-simple-light-mode](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-simple-light-mode/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-strategy-memorandum](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-strategy-memorandum/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-system-design](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-system-design/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-team-alignment](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-team-alignment/SKILL.md)
- [codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-three-statement-forecast](archive/codex-plugins/openai-curated-remote/openai-templates/0.1.1/skills/artifact-template-three-statement-forecast/SKILL.md)
- [codex-plugins/openai-curated-remote/plugin-management/0.1.0/skills/plugin-management](archive/codex-plugins/openai-curated-remote/plugin-management/0.1.0/skills/plugin-management/SKILL.md)
- [codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-building](archive/codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-building/SKILL.md)
- [codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-hosting](archive/codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-hosting/SKILL.md)
- [codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-preview-troubleshooting](archive/codex-plugins/openai-curated-remote/sites/0.1.62/skills/sites-preview-troubleshooting/SKILL.md)
- [codex-plugins/openai-primary-runtime/documents/26.905.11957/skills/documents](archive/codex-plugins/openai-primary-runtime/documents/26.905.11957/skills/documents/SKILL.md)
- [codex-plugins/openai-primary-runtime/pdf/26.905.11957/skills/pdf](archive/codex-plugins/openai-primary-runtime/pdf/26.905.11957/skills/pdf/SKILL.md)
- [codex-plugins/openai-primary-runtime/presentations/26.905.11957/skills/presentations](archive/codex-plugins/openai-primary-runtime/presentations/26.905.11957/skills/presentations/SKILL.md)
- [codex-plugins/openai-primary-runtime/spreadsheets/26.905.11957/skills/excel-live-control](archive/codex-plugins/openai-primary-runtime/spreadsheets/26.905.11957/skills/excel-live-control/SKILL.md)
- [codex-plugins/openai-primary-runtime/spreadsheets/26.905.11957/skills/spreadsheets](archive/codex-plugins/openai-primary-runtime/spreadsheets/26.905.11957/skills/spreadsheets/SKILL.md)
- [codex-plugins/openai-primary-runtime/template-creator/26.905.11957/skills/template-creator](archive/codex-plugins/openai-primary-runtime/template-creator/26.905.11957/skills/template-creator/SKILL.md)
- [codex/.system/imagegen](archive/codex/.system/imagegen/SKILL.md)
- [codex/.system/openai-docs](archive/codex/.system/openai-docs/SKILL.md)
- [codex/.system/plugin-creator](archive/codex/.system/plugin-creator/SKILL.md)
- [codex/.system/review-agent](archive/codex/.system/review-agent/SKILL.md)
- [codex/.system/skill-creator](archive/codex/.system/skill-creator/SKILL.md)
- [codex/.system/skill-installer](archive/codex/.system/skill-installer/SKILL.md)
