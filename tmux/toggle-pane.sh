#!/bin/bash

# Generic toggle sidebar pane with parent window tracking and mutual exclusion

cleanup_orphans() {
    if ! tmux has-session -t _scratchpad 2>/dev/null; then
        return
    fi
    local alive_windows
    alive_windows=$(tmux list-windows -a -F "#{window_id}")

    # Terminate background panes whose parent window no longer exists
    tmux list-panes -s -t _scratchpad -F "#{pane_id} #{@parent_window}" 2>/dev/null | while read -r pane_id parent_win; do
        if [ -n "$parent_win" ]; then
            if ! echo "$alive_windows" | grep -qx "$parent_win"; then
                tmux kill-pane -t "$pane_id" 2>/dev/null
            fi
        fi
    done
}

# Handle standalone hook cleanup execution
if [ "$1" = "--cleanup" ]; then
    cleanup_orphans
    exit 0
fi

CMD="${1:-$SHELL}"
WIDTH="${2:-20%}"
TAG="${3:-$(echo "$CMD" | awk '{print $1}')}"
TAG="$(echo -n "$TAG" | tr -c 'a-zA-Z0-9_' '_')"

CURRENT_WIN=$(tmux display-message -p "#{window_id}")
CURRENT_PATH=$(tmux display-message -p "#{pane_current_path}")

# Prevent _scratchpad from ever being picked as the current window
CURRENT_SESS=$(tmux display-message -p -t "$CURRENT_WIN" "#{session_name}" 2>/dev/null)
if [ "$CURRENT_SESS" = "_scratchpad" ]; then
    CURRENT_WIN=$(tmux list-windows -a -F "#{session_name} #{window_id}" | grep -v "^_scratchpad " | head -n1 | awk '{print $2}')
    CURRENT_PATH=$(tmux display-message -p -t "$CURRENT_WIN" "#{pane_current_path}" 2>/dev/null)
fi

# Maintain scratchpad sink session
if ! tmux has-session -t _scratchpad 2>/dev/null; then
    tmux new-session -d -s _scratchpad -n _keepalive
fi

# Clean up any stale panes from closed windows
cleanup_orphans

# 1. Check if ANY toggle pane is currently visible in the active window
VIS_INFO=$(tmux list-panes -t "$CURRENT_WIN" -F "#{pane_id}:#{@is_toggle_pane}:#{@toggle_tag}" | awk -F: '$2 == "1" {print; exit}')

if [ -n "$VIS_INFO" ]; then
    VIS_PANE_ID=$(echo "$VIS_INFO" | cut -d: -f1)
    VIS_TAG=$(echo "$VIS_INFO" | cut -d: -f3)

    if [ "$VIS_TAG" = "$TAG" ]; then
        # Same toggle triggered: hide it and stop
        tmux break-pane -d -s "$VIS_PANE_ID" -t _scratchpad:
        SAVED_LAYOUT=$(tmux display-message -p -t "$CURRENT_WIN" "#{@toggle_saved_layout}")
        if [ -n "$SAVED_LAYOUT" ]; then
            tmux select-layout -t "$CURRENT_WIN" "$SAVED_LAYOUT" 2>/dev/null || true
            tmux set-option -u -w -t "$CURRENT_WIN" @toggle_saved_layout 2>/dev/null || true
        fi
        exit 0
    else
        # Different toggle triggered: stash visible one first before showing requested one
        tmux break-pane -d -s "$VIS_PANE_ID" -t _scratchpad:
        SAVED_LAYOUT=$(tmux display-message -p -t "$CURRENT_WIN" "#{@toggle_saved_layout}")
        if [ -n "$SAVED_LAYOUT" ]; then
            tmux select-layout -t "$CURRENT_WIN" "$SAVED_LAYOUT" 2>/dev/null || true
        fi
    fi
else
    # No toggle pane currently visible: save window layout before opening one
    SAVED_LAYOUT=$(tmux display-message -p -t "$CURRENT_WIN" "#{window_layout}")
    tmux set-option -w -t "$CURRENT_WIN" @toggle_saved_layout "$SAVED_LAYOUT"
fi

# 2. Locate existing target pane for the current window and tag
TARGET_PANE=$(tmux list-panes -a -F "#{pane_id}:#{@parent_window}:#{@toggle_tag}" | grep ":${CURRENT_WIN}:${TAG}$" | cut -d: -f1 | head -n1)

if [ -n "$TARGET_PANE" ]; then
    # Bring hidden pane back from scratchpad into the current window
    tmux join-pane -f -h -l "$WIDTH" -s "$TARGET_PANE" -t "$CURRENT_WIN"
    tmux select-pane -t "$TARGET_PANE"
else
    # Spawn fresh pane explicitly targeting the active window (spans full window height)
    NEW_PANE=$(tmux split-window -f -t "$CURRENT_WIN" -h -l "$WIDTH" -c "$CURRENT_PATH" -P -F "#{pane_id}" "$CMD")
    tmux set-option -p -t "$NEW_PANE" @is_toggle_pane 1
    tmux set-option -p -t "$NEW_PANE" @toggle_tag "$TAG"
    tmux set-option -p -t "$NEW_PANE" @parent_window "$CURRENT_WIN"
    tmux select-pane -t "$NEW_PANE"
fi
