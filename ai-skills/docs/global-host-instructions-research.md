# Global host instruction mechanisms

Research date: 2026-09-14

## Finding

A model provider does not read instruction files from the computer. The host application builds the prompt and sends it to the selected model. A Grok model running inside Cursor therefore follows Cursor's rules, while the same model running inside Grok Build follows Grok Build's rules.

There is no system-wide instruction filename shared by all hosts. Reliable coverage requires one canonical instruction document plus a host-native adapter for every application. The adapter must be copied or generated when the host does not document external imports or symlink behavior.

## Supported host controls

| Host | Persistent user-level control | Automatic behavior and caveats |
| --- | --- | --- |
| Codex CLI, IDE, and Codex sessions in the desktop app | `~/.codex/AGENTS.md`, or `$CODEX_HOME/AGENTS.md` | Codex loads it once when a run or TUI session starts. `AGENTS.override.md` in the same directory replaces `AGENTS.md`. Project files are appended later and can override global guidance. The combined default limit is 32 KiB. [OpenAI documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md) |
| ChatGPT chat and Work | Settings > Personalization > Custom instructions | Account or app configuration, not a local Markdown file. It applies across chats when enabled. OpenAI documents the global `AGENTS.md` file specifically for Codex. [OpenAI documentation](https://learn.chatgpt.com/docs/personalize) |
| Claude Code | `~/.claude/CLAUDE.md` and unscoped `~/.claude/rules/*.md` | Claude Code loads user instructions every session. Project instructions load later and have higher priority. Linux also supports the administrator-controlled `/etc/claude-code/CLAUDE.md`. Claude Code does not natively treat `AGENTS.md` as its instruction file, but `CLAUDE.md` can import one. This controls Claude Code, not ordinary claude.ai chats. [Claude Code documentation](https://code.claude.com/docs/en/memory) |
| Gemini CLI | `~/.gemini/GEMINI.md` | Loaded automatically as global context and concatenated into the system prompt. The filename is configurable through `context.fileName` in `~/.gemini/settings.json`. Project and subdirectory context can supplement or override it. Verify with `/memory show`; reload with `/memory refresh`. [Gemini CLI configuration](https://github.com/google-gemini/gemini-cli/blob/main/docs/reference/configuration.md#context-files-hierarchical-instructional-context) |
| OpenCode | `~/.config/opencode/AGENTS.md` | Applied across OpenCode sessions. If it is absent, OpenCode falls back to `~/.claude/CLAUDE.md` unless Claude compatibility is disabled. The global `opencode.json` can also list files under `instructions`. [OpenCode rules](https://opencode.ai/docs/rules/) |
| Cursor Agent | Reliable global control: User Rules in Customize > Rules. File-backed automation: a local Cursor plugin under `~/.cursor/plugins/local/<plugin>/` containing an always-applied `.mdc` rule. | User Rules apply across projects. Current help documentation also mentions `~/.cursor/rules`, but the main rules reference still defines user rules through Customize, so direct home-directory rule loading is version-dependent. Local plugins require a reload and may be blocked by team policy. Rules affect Agent Chat, not Tab completion, Inline Edit, or Bugbot reviews. [Cursor rules](https://prod.cursor.com/docs/rules), [Cursor local plugins](https://prod.cursor.com/docs/plugins#test-plugins-locally) |
| GitHub Copilot CLI | `$COPILOT_HOME/copilot-instructions.md`, defaulting to `~/.copilot/copilot-instructions.md`; modular files under `$COPILOT_HOME/instructions/**/*.instructions.md` | Personal instructions load across repositories. `/instructions` can disable individual sources, and `--no-custom-instructions` disables them. When multiple files apply, Copilot combines them and does not define a general precedence order, so the files must not conflict. These paths control Copilot CLI, not every Copilot surface. [GitHub Copilot CLI documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions) |
| Crush | `~/.config/crush/CRUSH.md` and `~/.config/AGENTS.md` | Crush automatically includes both as additions to its system prompt. It follows `XDG_CONFIG_HOME`. Extra files or directories can be registered with repeated `option global-context-path` entries in the global `crushrc`. [Crush repository documentation](https://github.com/charmbracelet/crush#global-context-files) |
| Grok Build CLI | `$GROK_HOME/rules/*.md`, defaulting to `~/.grok/rules/*.md` | Home rules load automatically for every project before project rules. Grok also reads compatible `~/.claude/CLAUDE.md`, `~/.claude/rules/`, and Cursor sources by default, but the native rules directory avoids depending on compatibility settings. Verify with `grok inspect`. This controls Grok Build, not grok.com or bare xAI API calls. [Grok Build project-rules documentation](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/12-project-rules.md) |

## Local-model runtimes and APIs

| Runtime or interface | Available persistent mechanism | Limitation |
| --- | --- | --- |
| Ollama | Put `SYSTEM """..."""` in a `Modelfile`, then create and run a named model alias. [Ollama Modelfile reference](https://github.com/ollama/ollama/blob/main/docs/modelfile.mdx) | This belongs to the created model alias. Ollama does not document a universal user instruction file that is injected into every model and request. A client may supply a different system message. |
| LM Studio app | A preset under `~/.lmstudio/config-presets` can contain a system prompt. [LM Studio presets](https://lmstudio.ai/docs/app/presets) | Presets are selected or associated with chats; the documentation does not describe one preset that is forced into every chat. `lms chat` accepts `--system-prompt`, and API callers supply `system_prompt` or a system message themselves. [LM Studio CLI](https://lmstudio.ai/docs/cli/local-models/chat) |
| Generic OpenAI-compatible client | Send the canonical text as a `developer` or `system` message on every request. | The protocol does not define a host filesystem location. In the Responses API, `instructions` are not carried forward automatically when using `previous_response_id`, so the caller must resend them. [OpenAI API reference](https://developers.openai.com/api/reference/cli/resources/responses/methods/create) |

Ollama and LM Studio are runtimes. They do not turn a model into an agent that can discover `AGENTS.md`, skills, tools, or project context. The client or agent harness in front of the runtime provides those features.

## Machine inventory

Launch commands are present for `codex`, `claude`, `gemini`, `opencode`, `cursor`, `copilot`, `crush`, and `grok`. Codex and Cursor have installed runtimes. The other six commands are local wrapper scripts that ask Mise to install or run the current version, and their runtimes are not presently cached under the Mise installation directory. Their first successful launch will require Mise to obtain the package. `ollama`, `lms`, and `lmstudio` were not found on `PATH`.

The expected host directories exist for Codex, Claude Code, OpenCode, Cursor, and the shared `~/.agents` skills directory. The audit did not find an existing global `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `copilot-instructions.md`, or Cursor `.mdc` rule in the inspected user configuration roots. Gemini, Copilot, Crush, and Grok have binaries installed but have not created their default configuration directories.

## Implementation implications

Use a canonical source file in the managed repository, then install short host-specific files in the paths above. Do not assume that `~/.agents/skills` or one root-level `AGENTS.md` reaches every host.

For hosts with native file imports, an adapter may import the canonical source. Claude Code and Gemini CLI document absolute imports, and Crush can register the canonical path directly. OpenCode can load the canonical file through the global `instructions` setting. For hosts whose documentation restricts imports or symlinks, generate a normal file and record a checksum so updates stay auditable. Copilot imports must remain inside its custom-instructions directory. Cursor rejects local-plugin symlinks that resolve outside its plugin directory.

ChatGPT Custom Instructions and Cursor User Rules require application settings rather than an ordinary filesystem copy. Ollama aliases and LM Studio presets require separate generation and explicit selection, or a wrapper that sends the system prompt on every request.
