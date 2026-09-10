# ⚡ cheat-sheet

> An ultra-fast, zero-dependency interactive cheatsheet viewer and alias navigator for your terminal, with seamless Shell and Tmux integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-lightgrey.svg)]()

---

## ✨ Features

- 🚀 **Zero External Dependencies**: Built entirely with the Python 3 standard library (`curses`, `urllib`). No `pip`, no heavy runtimes, runs everywhere instantly.
- 🎯 **Interactive TUI**:
  - Full-screen or split-pane curses interface.
  - Smart word wrapping with preserved indentation and line numbers.
  - Active line highlight with dedicated command styling.
  - Real-time search (`/`) with match highlighting and cycling (`n` / `N`).
- ⚡ **Direct Command Injection**:
  - Press `Enter` on any command to paste it directly into your active shell prompt or Tmux pane.
  - Press `y` to yank/copy the command straight to your system clipboard (`wl-copy`, `xclip`, `pbcopy`).
- 📂 **Custom Cheatsheets (`c`)**:
  - Press `c` to open your custom cheatsheets browser.
  - Manage and load your own `.txt` or `.md` sheets from `~/.cheat-sheet/sheets/`.
- 🏷️ **Active Alias Browser (`a`)**:
  - Press `a` to browse, search, and inject your shell's active aliases (prioritizes explicitly defined aliases from your `.zshrc`).
- 🌐 **Multi-Source & Offline Cache**:
  - Fetches command references on-demand from community sources (`cheat.sh`, `tldr`, etc.).
  - Automatic offline caching in `~/.cache/cheat-sheet/` for instant subsequent lookups without network access.
- 🎨 **Nord Theme & Preset Palette**:
  - Built-in Nord color theme by default.
  - Themes available: `nord`, `dracula`, `gruvbox`, `catppuccin`, `monokai`, and `classic`.
  - Fully customizable via environment variables.
- 🪟 **Tmux & Shell Keybindings**:
  - Context-aware `Alt + /` widget for Zsh and Bash: typing `docker run` and pressing `Alt + /` automatically opens the `docker` cheatsheet.
  - Tmux sidebar scratchpad integration: slides out a sidebar pane and sends commands back to your active pane without switching context.

---

## 📦 Installation

### Quick Install

Clone the repository and run the installer:

```bash
git clone https://github.com/YOUR_USERNAME/cheat-sheet.git ~/.local/share/cheat-sheet
cd ~/.local/share/cheat-sheet
./install.sh
```

The installer will:
1. Symlink `bin/cheat-sheet` to `~/.local/bin/cheat-sheet`.
2. Initialize `~/.cheat-sheet/sheets/` with starter cheatsheets (`git`, `docker`, `tmux`, `tar`, `find`).

Ensure `~/.local/bin` is in your `PATH`:
```bash
# In ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

### Manual Install

Simply symlink or copy `bin/cheat-sheet` into any directory on your `$PATH`:

```bash
ln -s "/path/to/cheat-sheet/bin/cheat-sheet" ~/.local/bin/cheat-sheet
chmod +x ~/.local/bin/cheat-sheet
```

---

## ⌨️ Shell Integration (`Alt + /`)

Context-aware keybinding: inspects your current shell buffer and automatically opens the cheatsheet for the command you are typing.

### Zsh

Add to your `~/.zshrc`:

```zsh
source "/path/to/cheat-sheet/shell/cheat-sheet.zsh"
```

*Default keybinding: `Alt + /` (or `Esc` followed by `/`).*

To change the keybinding, configure `bindkey` in your `~/.zshrc`:
```zsh
bindkey '^F' _tmux_cheat_widget  # Bind to Ctrl + F
```

### Bash

Add to your `~/.bashrc`:

```bash
source "/path/to/cheat-sheet/shell/cheat-sheet.bash"
```

*Default keybinding: `Alt + /`.*

---

## 🪟 Tmux Integration

When running inside Tmux, pressing `Alt + /` can toggle a lateral sidebar scratchpad pane on the right (35% width). Pressing `Enter` inside the sidebar automatically injects the selected command directly into your active working pane!

If you want a dedicated Tmux keybinding (e.g. `prefix + i`), add this to your `~/.tmux.conf`:

```tmux
# Toggle cheat-sheet sidebar pane
bind-key i run-shell "/path/to/cheat-sheet/tmux/toggle-cheat-sheet.sh"
```

---

## 🚀 Usage

### Command Line

```bash
# Open interactive welcome / help page
cheat-sheet

# Open cheatsheet for a specific command
cheat-sheet git
cheat-sheet docker
cheat-sheet tar

# Search a topic or query directly
cheat-sheet "tar extract gz"

# Open directly into your custom sheets browser
cheat-sheet -c

# Open directly into your aliases browser
cheat-sheet -a
```

### Interactive Navigation & Keybindings

| Key | Action |
|:---|:---|
| `j` / `↓` | Scroll down one line |
| `k` / `↑` | Scroll up one line |
| `d` / `Ctrl+d` | Scroll half-page down |
| `u` / `Ctrl+u` | Scroll half-page up |
| `g` / `Home` | Jump to the beginning |
| `G` / `End` | Jump to the end |
| `/` | Start interactive search filter |
| `n` | Jump to next search match |
| `N` | Jump to previous search match |
| `Enter` | **Inject command** into terminal / Tmux pane |
| `y` | **Yank / copy** selected command to clipboard |
| `c` | Open **Custom Cheatsheets** browser |
| `a` | Open **Aliases** browser |
| `Esc` | Clear search query / Reset highlights |
| `q` | Quit viewer |

---

## 📝 Custom Cheatsheets

Place your own cheatsheet files in `~/.cheat-sheet/sheets/` (or `~/.config/cheat-sheet/sheets/`).

Supported file formats: `.txt`, `.md`.

### Syntax Example (`~/.cheat-sheet/sheets/docker.txt`):

```txt
# Build an image from a Dockerfile
docker build -t my-app .

# Run container with port forwarding and interactive tty
docker run -it --rm -p 8080:80 my-app

# Inspect running container logs
docker logs -f --tail 100 <container_id>

# Clean up dangling images and stopped containers
docker system prune -af --volumes
```

- Lines starting with `#` are formatted as descriptive comments.
- Command lines are automatically highlighted and selectable with `Enter` or `y`.

---

## 🎨 Themes & Customization

### Preset Themes

Select a preset theme using the `CHEAT_SHEET_THEME` environment variable:

```bash
export CHEAT_SHEET_THEME="nord"         # Default
# Options: nord, dracula, gruvbox, catppuccin, monokai, classic
```

### Custom Theme Variables

You can customize individual colors in your shell profile:

| Variable | Description |
|:---|:---|
| `CHEAT_SHEET_COLOR_BG` | Terminal background color (-1 for terminal default) |
| `CHEAT_SHEET_COLOR_FG` | Default text color |
| `CHEAT_SHEET_COLOR_COMMENT` | Comment lines (`# ...`) |
| `CHEAT_SHEET_COLOR_COMMAND` | Command text color |
| `CHEAT_SHEET_COLOR_COMMAND_ACTIVE` | Currently highlighted command text |
| `CHEAT_SHEET_COLOR_COMMAND_BG` | Background highlight for active command line |
| `CHEAT_SHEET_COLOR_HEADER` | Header bar background |
| `CHEAT_SHEET_COLOR_HEADER_FG` | Header bar text |
| `CHEAT_SHEET_COLOR_STATUS` | Status line background |
| `CHEAT_SHEET_COLOR_STATUS_FG` | Status line text |
| `CHEAT_SHEET_COLOR_SEARCH_MATCH` | Search match highlight text color |
| `CHEAT_SHEET_COLOR_SEARCH_MATCH_BG` | Search match highlight background |

Colors accept standard curses names (`default`, `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`) or 256-color palette integers (`0` - `255`).

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
