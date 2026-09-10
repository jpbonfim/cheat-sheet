# ==============================================================================
# cheat-sheet.bash - Bash keybinding & helper integration for cheat-sheet
# ==============================================================================
# Add to your ~/.bashrc:
#   source /path/to/cheat-sheet/shell/cheat-sheet.bash
#
# Shortcuts:
#   Alt + /   Opens cheat-sheet for the command currently typed in the prompt
#   cheat     Alias for cheat-sheet
# ==============================================================================

_bash_cheat_widget() {
  local cmd="${READLINE_LINE%% *}"
  local first second _rest
  read -r first second _rest <<< "$READLINE_LINE"
  case "$first" in
    git|docker|kubectl|npm|cargo|tmux|ip|systemctl)
      if [[ -n "$second" && "$second" != -* ]]; then
        cmd="$first $second"
      fi
      ;;
  esac

  if [[ -n "$TMUX" ]]; then
    local toggle_script
    if command -v toggle-cheat-sheet.sh >/dev/null 2>&1; then
      toggle_script="$(command -v toggle-cheat-sheet.sh)"
    elif [[ -x "${HOME}/.tmux/scripts/toggle-cheat-sheet.sh" ]]; then
      toggle_script="${HOME}/.tmux/scripts/toggle-cheat-sheet.sh"
    elif [[ -x "${HOME}/.local/bin/toggle-cheat-sheet.sh" ]]; then
      toggle_script="${HOME}/.local/bin/toggle-cheat-sheet.sh"
    else
      local script_dir
      script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tmux" 2>/dev/null && pwd)/toggle-cheat-sheet.sh"
      if [[ -x "$script_dir" ]]; then
        toggle_script="$script_dir"
      fi
    fi

    if [[ -n "$toggle_script" ]]; then
      if [[ -n "$cmd" ]]; then
        tmux run-shell "\"$toggle_script\" '$cmd'"
      else
        tmux run-shell "\"$toggle_script\""
      fi
      return
    fi
  fi

  local sel_file
  sel_file="$(mktemp "${TMPDIR:-/tmp}/cheat-sel.XXXXXX")"
  if [[ -n "$cmd" ]]; then
    CHEAT_SHEET_SELECTION_FILE="$sel_file" cheat-sheet "$cmd" </dev/tty >/dev/tty 2>&1
  else
    CHEAT_SHEET_SELECTION_FILE="$sel_file" cheat-sheet </dev/tty >/dev/tty 2>&1
  fi
  if [[ -s "$sel_file" ]]; then
    READLINE_LINE="$(<"$sel_file")"
    READLINE_POINT=${#READLINE_LINE}
  fi
  rm -f "$sel_file"
}

bind -x '"\e/": _bash_cheat_widget'
alias cheat="cheat-sheet"
