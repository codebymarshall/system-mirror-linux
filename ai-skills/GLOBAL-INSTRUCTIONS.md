# Global agent instructions

These instructions apply to every project and every interaction in this host.

## Priority

- Follow the host's system, developer, safety, and permission rules first.
- Follow the user's current instructions before skill guidelines. A skill does not expand the user's authorization.
- Let more specific project instructions refine these global instructions according to the host's normal precedence rules.

## Always active

Treat `unslop` as a standing writing policy. Before sending user-facing prose, read the complete `unslop/SKILL.md` from an available skill root if it has not already been loaded in the current session, then apply it. This rule is an explicit exception to `unslop` being marked as user-invoked. Apply it to original prose, not source code, literal quotations, logs, or text the user requires verbatim.

If the skill file cannot be read, use this fallback: write plain, direct, concrete prose; prefer active voice; remove filler, canned chatbot phrases, vague claims, decorative formatting, forced groupings, abstract jargon, and AI-sounding flourishes; avoid em dashes; preserve the intended meaning and tone.

No other saved skill is active on every interaction.

## Skill routing

Before substantive work, match the request against the task-triggered skills below. Load every matching skill before taking task actions. Read its complete `SKILL.md`, resolve relative references from that skill's directory, and load only the supporting material needed for the current branch.

Use native skill invocation when the host supports it. Otherwise, read the matching skill directly from the first available location:

- `~/.agents/skills/<skill>/SKILL.md`
- `~/.claude/skills/<skill>/SKILL.md`
- `~/.grok/skills/<skill>/SKILL.md`
- `~/.hermes/skills/<skill>/SKILL.md`

The saved catalog is normally available at `~/Github/system-mirror-linux/ai-skills/CATALOG.md` on this Linux machine.

### Task-triggered skills

| Skill | Required trigger |
| --- | --- |
| `code-review` | Review a branch, pull request, work-in-progress changes, or changes since a fixed point. |
| `codebase-design` | Design or restructure code, change a module interface, choose a seam, or improve testability. |
| `diagnosing-bugs` | Diagnose or debug broken, failing, crashing, throwing, or slow behavior. |
| `domain-modeling` | Change project terminology or the domain model, or write `CONTEXT.md` or an ADR. |
| `find-skills` | Find or install a capability that may exist as an agent skill. |
| `grilling` | Stress-test a plan, decision, or idea, or respond to an explicit grilling request. |
| `prototype` | Build a throwaway prototype to answer a logic, state-model, or interface design question. |
| `research` | Research a topic, documentation, or API facts and capture sourced findings in the repository. |
| `tdd` | The user requests test-first development, red-green-refactor, or integration tests. |
| `wizard` | Create an interactive guide for human-only setup, credentials, infrastructure, migration, or cutover steps. |
| `writing-for-agents` | Create or edit a skill, `AGENTS.md`, `CLAUDE.md`, or another document written for agents. |

## User-invoked workflows

Do not start these workflows unless the user explicitly names or requests them: `grill-me`, `grill-with-docs`, `handoff`, `implement`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, `teach`, `triage`, `wait-what`, and `wayfinder`.

`setup-matt-pocock-skills` is a one-time repository prerequisite, not an every-session rule. If another engineering workflow needs its files and they are missing, explain that prerequisite instead of silently running the setup workflow.

## Hosts and models

The host application loads instructions and skills. The selected model provider does not discover files by itself. Apply this same policy when the host switches among OpenAI, Anthropic, xAI, Google, or local models. If a chat client cannot load files or skills, use the always-active writing fallback above and state that task-specific skill execution is unavailable rather than claiming the skill ran.
