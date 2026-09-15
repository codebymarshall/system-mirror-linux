# Using the library on another agent

Read the catalog and choose the skill that matches the user's task. Read its complete SKILL.md before acting. Resolve relative references against that skill's folder. Load supporting files only when the task needs them.

The saved skill contents retain their original host terminology. Apply these adaptations when using them on a different host:

- If a skill says to call the Skill tool, use native skill invocation when available. Otherwise read and follow the named sibling folder's SKILL.md. For example, grill-me uses grilling; grill-with-docs uses grilling and domain-modeling.
- Map file reading, searching, shell execution, web browsing, and questions to the host's available tools. A textual instruction does not create a tool.
- If a workflow requests subagents and the host supports them, use the host's delegation mechanism. If it does not, perform the separate analyses sequentially and disclose that limitation.
- Run Bash scripts using Bash on Linux or Git Bash/WSL on Windows. Use the installed copy, whose Bash line endings the installer converts to LF. Invoke template scripts through bash so a Windows checkout does not need Unix executable bits. Translate ordinary shell examples to the current shell where that preserves their behavior.
- GitHub and GitLab workflows need the corresponding CLI and authentication. Follow setup-matt-pocock-skills when configuring its engineering workflow for a new repo. Follow its local issue-tracker option when appropriate.
- Read archive skills as references until their actual tool and runtime dependencies are available. Report a missing capability instead of fabricating a tool result.
- Honor the current user's instructions and the host's permission boundaries. Importing a workflow does not itself authorize messages, uploads, publishing, payments, or other external actions.
- Preserve explicit-invocation settings where the host supports them. Frontmatter and agents/openai.yaml are host metadata; another host may interpret them differently.

Completion means the requested workflow produced a checked result, or the agent identified the exact missing capability. Finding or loading a skill alone does not complete the user's task.

## Global policy

[GLOBAL-INSTRUCTIONS.md](GLOBAL-INSTRUCTIONS.md) defines the cross-host standing policy and the authoritative automatic versus user-invoked skill routing. Install it with `python3 scripts/skills.py install-instructions`. A model provider does not read this file directly; Codex, Claude Code, Grok Build, another agent host, or an API client must add it to the model's context.
