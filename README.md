# cheat-sheet

A fast, zero-dependency interactive cheatsheet viewer and alias navigator for the terminal, featuring seamless Shell and Tmux integration.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-lightgrey.svg)]()

---

## Overview

`cheat-sheet` provides instant access to command-line references, personal cheatsheets, and shell aliases directly inside your terminal workflow. Built entirely using the Python standard library, it requires no external packages and launches instantly as a full-screen TUI or a slide-out Tmux sidebar pane.

## Features

- **Zero External Dependencies**: Implemented purely with Python 3 standard library modules (`curses`, `urllib`). No `pip` installations or heavy runtime dependencies required.
- **Multi-Source Documentation**:
  - Automatically queries community documentation (`cheat.sh`).
  - Seamlessly falls back to local `man` pages and `--help` output.
  - Supports personal cheatsheets (`~/.cheat-sheet/sheets/`).
  - Dynamically cycles across available sources (`t`).
- **Interactive Curses TUI**:
  - Full-screen viewer or compact side-pane display.
  - Smart word wrapping tailored for narrow panes, preserving indentation.
  - In-document search (`/`) with match highlighting and cycling (`n` / `N`).
  - Command example navigation with `Tab` / `Shift+Tab`.
- **Command Injection & Clipboard Integration**:
  - Press `Enter` to inject the selected command directly into your active shell prompt or Tmux target pane.
  - Press `y` to copy commands to clipboard via OSC 52, `wl-copy`, `xclip`, `pbcopy`, or Tmux buffer.
- **Shell & Tmux Workflow**:
  - Context-aware `Alt + /` widget for Zsh and Bash: detects the command currently typed at the prompt (including compound commands like `docker run` or `git commit`) and opens relevant documentation.
  - Slide-out Tmux sidebar scratchpad (35% width) that preserves your active working context.
- **Personal Sheets & Alias Navigation**:
  - Browse and search custom `.txt` and `.md` cheatsheets (`c`).
  - Browse, filter, and inject active shell aliases (`a`), prioritizing definitions from `.zshrc`.
- **Offline Caching**:
  - Automatic caching in `~/.cache/cheat-sheet/` ensures instantaneous lookups without network access.
- **Theme Support**:
  - Default Nord palette with built-in presets: `nord`, `dracula`, `gruvbox`, `catppuccin`, `monokai`, and `classic`.

## Installation

### Prerequisites

- Python 3.8 or newer (`curses` support enabled)
- Bash or Zsh (optional, for shell widgets)
- Tmux (optional, for sidebar scratchpad integration)
- Clipboard utility (optional: `wl-copy`, `xclip`, `pbcopy`, or terminal with OSC 52 support)

### Automated Install

Clone the repository and run the installation script:

```bash
git clone https://github.com/jpbonfim/cheat-sheet.git ~/.local/share/cheat-sheet
cd ~/.local/share/cheat-sheet
./install.sh
```

The installer will:
1. Symlink `bin/cheat-sheet` to `~/.local/bin/cheat-sheet`.
2. Seed starter cheatsheets into `~/.cheat-sheet/sheets/` (`git`, `docker`, `tmux`, `tar`, `find`).

Ensure `~/.local/bin` is present in your `PATH`:

```bash
# In ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

### Manual Install

Symlink the executable to any directory on your `$PATH`:

```bash
ln -s "/path/to/cheat-sheet/bin/cheat-sheet" ~/.local/bin/cheat-sheet
chmod +x ~/.local/bin/cheat-sheet
```

## Shell Integration

The shell integration binds `Alt + /` to inspect the command currently entered at the prompt and launch documentation for it. If the prompt line is empty, it opens the interactive search and welcome guide.

### Zsh

Add the following to your `~/.zshrc`:

```zsh
source "/path/to/cheat-sheet/shell/cheat-sheet.zsh"
```

*Note: This also configures a `cheat` alias pointing to `cheat-sheet`.*

To customize the keybinding:
```zsh
bindkey '^F' _tmux_cheat_widget  # Example: bind to Ctrl + F
```

### Bash

Add the following to your `~/.bashrc`:

```bash
source "/path/to/cheat-sheet/shell/cheat-sheet.bash"
```

Default keybinding: `Alt + /`.

## Tmux Integration

When running within Tmux, triggering `Alt + /` opens a 35% lateral sidebar pane alongside your active pane. Pressing `Enter` on any command injects it straight into your active pane prompt and closes the sidebar.

To bind a dedicated shortcut (e.g., `prefix + i`), add the following to `~/.tmux.conf`:

```tmux
# Toggle cheat-sheet sidebar pane
bind-key i run-shell "/path/to/cheat-sheet/tmux/toggle-cheat-sheet.sh"
```

## Usage

### Command-Line Interface

```bash
# Open interactive welcome guide & search
cheat-sheet

# Open cheatsheet for a command or subcommand
cheat-sheet git
cheat-sheet docker run
cheat-sheet tar

# Search across topics
cheat-sheet "tar extract gz"

# Force refresh from remote source, bypassing local cache
cheat-sheet -r git

# Print directly to stdout without launching the TUI
cheat-sheet -n docker
```

### CLI Options

| Option | Description |
|:---|:---|
| `COMMAND` | Command or topic to look up (e.g. `tar`, `git commit`) |
| `-n`, `--no-pager` | Print cheatsheet directly to stdout without interactive TUI |
| `-r`, `--refresh` | Force re-fetch from online source, ignoring local cache |
| `--tmux-target PANE` | Specify target Tmux pane ID for command injection |
| `-h`, `--help` | Show command-line help message |

### Keyboard Shortcuts

| Key | Action |
|:---|:---|
| `j` / `↓` | Scroll down one line |
| `k` / `↑` | Scroll up one line |
| `d` / `Ctrl+d` | Scroll half page down |
| `u` / `Ctrl+u` | Scroll half page up |
| `g` / `Home` | Jump to top of document |
| `G` / `End` | Jump to bottom of document |
| `Tab` / `Shift+Tab` | Jump to next / previous executable command example |
| `Enter` | Inject selected command into shell prompt / Tmux pane |
| `y` | Copy selected command to clipboard (OSC 52, `wl-copy`, `xclip`, `pbcopy`) |
| `/` | Search text within current document |
| `n` / `N` | Jump to next / previous search match |
| `s`, `o` | Search / switch to another command |
| `t` | Cycle documentation source (`cheat.sh` ↔ `man` ↔ `--help` ↔ personal) |
| `[` / `]` or `H` / `L` | Navigate backward / forward in session command history |
| `r` | Reload current cheatsheet from remote source |
| `c` | Open personal cheatsheets browser |
| `a` | Open shell alias browser |
| `Esc` | Clear search query and active highlights |
| `q`, `Ctrl+C` | Quit viewer |

## Custom Cheatsheets

Personal cheatsheet files are stored in `~/.cheat-sheet/sheets/` (or `~/.config/cheat-sheet/sheets/`). Supported formats: `.txt` and `.md`.

### Syntax Example (`~/.cheat-sheet/sheets/docker.txt`)

```txt
# Build an image from a Dockerfile
docker build -t my-app .

# Run container with port forwarding and interactive TTY
docker run -it --rm -p 8080:80 my-app

# Inspect running container logs
docker logs -f --tail 100 <container_id>

# Clean up dangling images and stopped containers
docker system prune -af --volumes
```

- Lines starting with `#` are treated as descriptive comments.
- Command lines are automatically highlighted and selectable with `Enter` or `y`.

## Configuration

### Themes

Set the `CHEAT_SHEET_THEME` environment variable in your shell profile:

```bash
export CHEAT_SHEET_THEME="nord"
```

Available presets:
- `nord` (default)
- `dracula`
- `gruvbox`
- `catppuccin`
- `monokai`
- `classic`

### Environment Variables

| Variable | Default | Description |
|:---|:---|:---|
| `CHEAT_SHEET_THEME` | `nord` | Active color theme preset |
| `CHEAT_SHEET_CACHE_DIR` | `~/.cache/cheat-sheet` | Directory for cached remote cheatsheets |
| `CHEAT_SHEET_TARGET_PANE` | — | Target Tmux pane ID for command injection |
| `ESCDELAY` | `25` | Delay in milliseconds for escape sequence handling |

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/jpbonfim/cheat-sheet/issues).

## License

Distributed under the [MIT License](LICENSE).
