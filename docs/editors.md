# Editor extensions (Cursor + VS Code)

Extension IDs are plain text, one per line. After installing something new in the UI:

1. `cursor --list-extensions` (and/or `code --list-extensions`)
2. Add the ID to the right file under `dotfiles/editors/`
3. `make apply` — `run_onchange_install-editor-extensions.sh.tmpl` installs missing extensions

| File | Installed on |
| ------ | ---------------- |
| `extensions-common.txt` | Cursor + VS Code |
| `extensions-cursor.txt` | Cursor only |
| `extensions-work.txt` | `work` tag — Cursor + VS Code |

Requires `editors` in the tag allowlist (default on all profiles). Work extensions also need `work` tag — on a personal machine: `make apply EXTRA_VARS='-e workstation_tags_extra=[work]'`.

Settings and keybindings: `dotfiles/Library/Application Support/Cursor/User/` and `Code/User/`.

See [tags.md](tags.md) for the full tag model.

MCP secrets for Cursor: copy `dotfiles/dot_cursor/.env.example` → `~/.cursor/.env` (ignored by chezmoi).
