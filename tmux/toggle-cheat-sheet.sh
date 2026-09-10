#!/usr/bin/env bash
# ==============================================================================
# tmux/toggle-cheat-sheet.sh - Tmux slide-out cheatsheet panel integration
# ==============================================================================
# Inspects the command being typed in the active pane (ignoring terminal
# autosuggestions beyond cursor), or opens an empty prompt inside the viewer,
# and toggles a 35% lateral pane with interactive cheatsheet documentation.
# Passes the caller pane ID to enable direct command injection via Enter.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOGGLE_PANE="${SCRIPT_DIR}/toggle-pane.sh"

# Locate cheat-sheet executable
if command -v cheat-sheet >/dev/null 2>&1; then
    CHEAT_BIN="$(command -v cheat-sheet)"
elif [ -x "${HOME}/.local/bin/cheat-sheet" ]; then
    CHEAT_BIN="${HOME}/.local/bin/cheat-sheet"
elif [ -x "${HOME}/bin/cheat-sheet" ]; then
    CHEAT_BIN="${HOME}/bin/cheat-sheet"
elif [ -x "${SCRIPT_DIR}/../bin/cheat-sheet" ]; then
    CHEAT_BIN="${SCRIPT_DIR}/../bin/cheat-sheet"
else
    CHEAT_BIN="cheat-sheet"
fi

extract_cmd() {
    local raw="$1"
    raw="$(echo "$raw" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -z "$raw" ] && return 0

    local cleaned
    if echo "$raw" | grep -qE '[$#%❯➜>»]'; then
        cleaned="$(echo "$raw" | sed -E 's/^.*[$#%❯➜>»][[:space:]]*//')"
    else
        cleaned="$raw"
    fi
    [ -z "$cleaned" ] && return 0

    # Strip wrapper prefixes
    cleaned="$(echo "$cleaned" | sed -E 's/^(sudo|doas|nohup|env|time)[[:space:]]+//')"

    local first_word
    first_word="$(echo "$cleaned" | awk '{print $1}')"
    [ -z "$first_word" ] && return 0

    if echo "$first_word" | grep -qE '^[$#%❯➜>»]*$'; then
        return 0
    fi

    local bin_name
    bin_name="$(basename "$first_word" 2>/dev/null || echo "$first_word")"

    # Support common compound subcommands
    local second_word
    second_word="$(echo "$cleaned" | awk '{print $2}')"
    case "$bin_name" in
        git|docker|kubectl|npm|cargo|tmux|ip|systemctl)
            if [ -n "$second_word" ] && [[ ! "$second_word" =~ ^- ]]; then
                echo "$bin_name $second_word"
                return 0
            fi
            ;;
    esac

    echo "$bin_name"
}

CURRENT_WIN=$(tmux display-message -p "#{window_id}")

# Prevent _scratchpad from ever being picked as the current window
CURRENT_SESS=$(tmux display-message -p -t "$CURRENT_WIN" "#{session_name}" 2>/dev/null)
if [ "$CURRENT_SESS" = "_scratchpad" ]; then
    CURRENT_WIN=$(tmux list-windows -a -F "#{session_name} #{window_id}" | grep -v "^_scratchpad " | head -n1 | awk '{print $2}')
fi

# 1. If cheat-sheet toggle pane is currently visible in active window, toggle off (hide)
VIS_INFO=$(tmux list-panes -t "$CURRENT_WIN" -F "#{pane_id}:#{@is_toggle_pane}:#{@toggle_tag}" 2>/dev/null | awk -F: '$2 == "1" {print; exit}')
if [ -n "$VIS_INFO" ]; then
    VIS_TAG=$(echo "$VIS_INFO" | cut -d: -f3)
    if [ "$VIS_TAG" = "cheat_sheet" ] || [ "$VIS_TAG" = "cheat-sheet" ] || [ "$VIS_TAG" = "cheat" ]; then
        "$TOGGLE_PANE" "" 35% "$VIS_TAG"
        exit 0
    fi
fi

ACTIVE_PANE=$(tmux display-message -p "#{pane_id}")
CMD="$1"

# 2. If no command passed explicitly, inspect active terminal pane up to cursor_x
if [ -z "$CMD" ]; then
    CURSOR_Y=$(tmux display-message -t "$ACTIVE_PANE" -p "#{cursor_y}" 2>/dev/null || echo 0)
    CURSOR_X=$(tmux display-message -t "$ACTIVE_PANE" -p "#{cursor_x}" 2>/dev/null || echo 0)

    # Capture line at cursor row
    LINE=$(tmux capture-pane -p -t "$ACTIVE_PANE" -S "$CURSOR_Y" -E "$CURSOR_Y" 2>/dev/null)

    # Slice line up to cursor_x to ignore ghost autosuggestions past cursor
    TYPED_LINE=""
    if [ -n "$LINE" ] && [ "$CURSOR_X" -gt 0 ]; then
        TYPED_LINE="${LINE:0:CURSOR_X}"
    fi

    # Extract command from typed portion; if not found, fall back to full line
    CMD="$(extract_cmd "$TYPED_LINE")"
    if [ -z "$CMD" ] && [ -n "$LINE" ]; then
        CMD="$(extract_cmd "$LINE")"
    fi
fi

# 3. Clean up any stale hidden cheat pane from scratchpad so new query launches fresh
OLD_CHEAT=$(tmux list-panes -a -F "#{pane_id}:#{@parent_window}:#{@toggle_tag}" 2>/dev/null | grep -E ":${CURRENT_WIN}:(cheat_sheet|cheat-sheet|cheat)$" | cut -d: -f1)
if [ -n "$OLD_CHEAT" ]; then
    tmux kill-pane -t "$OLD_CHEAT" 2>/dev/null || true
fi

# 4. Launch toggle pane passing target pane ID for terminal injection
if [ -n "$CMD" ]; then
    "$TOGGLE_PANE" "${CHEAT_BIN} --tmux-target '${ACTIVE_PANE}' '${CMD}'" 35% "cheat_sheet"
else
    "$TOGGLE_PANE" "${CHEAT_BIN} --tmux-target '${ACTIVE_PANE}'" 35% "cheat_sheet"
fi
