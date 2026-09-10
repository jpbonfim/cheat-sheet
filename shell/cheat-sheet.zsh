# ==============================================================================
# cheat-sheet.zsh - Zsh keybinding & widget integration for cheat-sheet
# ==============================================================================
# Add to your ~/.zshrc:
#   source /path/to/cheat-sheet/shell/cheat-sheet.zsh
#
# Shortcuts:
#   Alt + /   Opens cheat-sheet for the command currently typed in the prompt
#             (or opens the interactive guide/search if line is empty).
#             Inside Tmux: slides out a 35% lateral side pane alongside your work.
#             Outside Tmux: opens interactive full-screen viewer.
#   cheat     Alias for cheat-sheet
# ==============================================================================

# Locate toggle-cheat-sheet.sh script
_find_tmux_cheat_script() {
  if command -v toggle-cheat-sheet.sh >/dev/null 2>&1; then
    echo "$(command -v toggle-cheat-sheet.sh)"
  elif [[ -x "${HOME}/.tmux/scripts/toggle-cheat-sheet.sh" ]]; then
    echo "${HOME}/.tmux/scripts/toggle-cheat-sheet.sh"
  elif [[ -x "${HOME}/.local/bin/toggle-cheat-sheet.sh" ]]; then
    echo "${HOME}/.local/bin/toggle-cheat-sheet.sh"
  else
    local script_dir="${0:A:h}/../tmux/toggle-cheat-sheet.sh"
    if [[ -x "$script_dir" ]]; then
      echo "$script_dir"
    else
      echo "toggle-cheat-sheet.sh"
    fi
  fi
}

_tmux_cheat_widget() {
  local cmd="${BUFFER%% *}"
  local first second
  read -r first second _ <<< "$BUFFER"
  case "$first" in
    git|docker|kubectl|npm|cargo|tmux|ip|systemctl)
      if [[ -n "$second" && "$second" != -* ]]; then
        cmd="$first $second"
      fi
      ;;
  esac

  if [[ -n "$TMUX" ]]; then
    local toggle_script
    toggle_script="$(_find_tmux_cheat_script)"
    if [[ -n "$cmd" ]]; then
      tmux run-shell "\"$toggle_script\" '$cmd'"
    else
      tmux run-shell "\"$toggle_script\""
    fi
  else
    zle -I
    local sel_file
    sel_file="$(mktemp "${TMPDIR:-/tmp}/cheat-sel.XXXXXX")"
    if [[ -n "$cmd" ]]; then
      CHEAT_SHEET_SELECTION_FILE="$sel_file" cheat-sheet "$cmd" </dev/tty >/dev/tty 2>&1
    else
      CHEAT_SHEET_SELECTION_FILE="$sel_file" cheat-sheet </dev/tty >/dev/tty 2>&1
    fi
    if [[ -s "$sel_file" ]]; then
      BUFFER="$(<"$sel_file")"
      CURSOR=${#BUFFER}
    fi
    rm -f "$sel_file"

    # Completely clear autosuggest ghost text and refresh prompt
    POSTDISPLAY=""
    if (( $+functions[_zsh_autosuggest_clear] )); then
      _zsh_autosuggest_clear
    fi
    zle reset-prompt
  fi
}

zle -N _tmux_cheat_widget
bindkey '^[\/' _tmux_cheat_widget  # Shortcut: Alt + /
alias cheat="cheat-sheet"

# Ensure zsh-autosuggestions clears ghost text when triggering the widget
if [[ -n "${ZSH_AUTOSUGGEST_CLEAR_WIDGETS+x}" ]]; then
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(_tmux_cheat_widget)
fi
