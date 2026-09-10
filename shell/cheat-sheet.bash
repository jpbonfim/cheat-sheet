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

  if [[ -n "$cmd" ]]; then
    cheat-sheet "$cmd" </dev/tty >/dev/tty 2>&1
  else
    cheat-sheet </dev/tty >/dev/tty 2>&1
  fi
}

bind -x '"\e/": _bash_cheat_widget'
alias cheat="cheat-sheet"
