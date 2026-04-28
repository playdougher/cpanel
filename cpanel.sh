#!/bin/bash

# Force terminal width to prevent background truncation at 80 columns
export COLUMNS=512

# Reuse or create temp files for logs and PID tracking
[ -z "$LOG_FILE" ] && export LOG_FILE=$(mktemp)
[ -z "$PID_FILE" ] && export PID_FILE=$(mktemp)

KILL_OLD="pid=\$(cat $PID_FILE 2>/dev/null); if [ -n \"\$pid\" ]; then pkill -9 -P \"\$pid\" 2>/dev/null; kill -9 \"\$pid\" 2>/dev/null; fi"

# Determine the absolute path of this script for fzf callbacks
SELF_PATH=$(readlink -f "$0")

# Background execution helper
run_bg() {
  local cmd="$1"
  eval "$KILL_OLD"
  echo "$cmd" >> "$HISTORY_FILE"
  echo -e "\n[Background Execution]: $cmd" >> "$LOG_FILE"
  
  if [[ "$cmd" == sudo* ]]; then
    # Pre-check sudo cache to avoid hanging in background
    if ! sudo -n true 2>/dev/null; then
      echo -e "\e[1;31m[!] Sudo password required. Background execution halted.\e[0m" >> "$LOG_FILE"
      echo -e "\e[1;33m[!] Please press [Ctrl+S] to authorize or [Ctrl+O] to run in foreground.\e[0m" >> "$LOG_FILE"
      return 1
    fi
    # Direct execution for sudo to share current TTY credentials
    eval "$cmd" >> "$LOG_FILE" 2>&1 &
  else
    # Use script for normal commands to preserve colors/formatting (creates new PTY)
    SYSTEMD_PAGER='' script -q -c "$cmd" /dev/null >> "$LOG_FILE" 2>&1 &
  fi
  echo $! > "$PID_FILE"
}

# Foreground execution helper
run_fg() {
  local cmd="$1"
  echo "$cmd" >> "$HISTORY_FILE"
  if [[ "$cmd" == sudo* ]]; then
    # Direct execution for sudo to share current TTY credentials
    eval "$cmd"
  else
    # Use script for normal commands to preserve colors/formatting
    SYSTEMD_PAGER='' script -q -c "$cmd" /dev/null
  fi
}

# Internal handling for fzf callbacks
if [[ "$1" == "--run-bg" ]]; then
  HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
  [ ! -f "$HISTORY_FILE" ] && HISTORY_FILE="$HOME/.zsh_history"
  run_bg "$2"
  exit 0
elif [[ "$1" == "--run-fg" ]]; then
  HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
  [ ! -f "$HISTORY_FILE" ] && HISTORY_FILE="$HOME/.zsh_history"
  run_fg "$2"
  exit 0
fi

# Main Instance Initialization
trap "$KILL_OLD; rm -f $LOG_FILE $PID_FILE" EXIT
[ ! -s "$LOG_FILE" ] && echo "=== Execution Log === (Press Ctrl+L to clear)" > "$LOG_FILE"

HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
if [ ! -f "$HISTORY_FILE" ]; then 
  HISTORY_FILE="$HOME/.zsh_history"
fi

RELOAD_CMD="\tail -n 5000 '$HISTORY_FILE' | sed -E 's/^: [0-9]+:[0-9]+;//' | sed '/^#/{d}' | tac | awk '!seen[\$0]++' | head -n 2000"

eval "$RELOAD_CMD" | fzf \
  --ansi \
  --tiebreak=index \
  --layout=reverse \
  --header="[Enter/Dbl-Click] Background | [Alt-Enter] Execute Input | [Ctrl+S] Sudo-Auth | [Right-Click/Ctrl+O] Foreground | [Ctrl+V] Fullscreen(less) | [Ctrl+L] Clear" \
  --preview="\tail -n 2000 $LOG_FILE" \
  --preview-window="right:60%:wrap:follow" \
  --bind='double-click:execute-silent('"$SELF_PATH"' --run-bg {})+reload('"$RELOAD_CMD"')' \
  --bind='enter:execute-silent('"$SELF_PATH"' --run-bg {})+reload('"$RELOAD_CMD"')' \
  --bind='alt-enter:execute-silent('"$SELF_PATH"' --run-bg {q})+reload('"$RELOAD_CMD"')' \
  --bind='ctrl-s:execute(sudo -v)' \
  --bind='right-click:execute('"$SELF_PATH"' --run-fg {})+reload('"$RELOAD_CMD"')' \
  --bind='ctrl-o:execute('"$SELF_PATH"' --run-fg {})+reload('"$RELOAD_CMD"')' \
  --bind='alt-j:jump' \
  --bind='ctrl-v:execute(less -RX +G '"$LOG_FILE"')' \
  --bind='ctrl-l:execute-silent(echo "=== Execution Log === (Press Ctrl+L to clear)" > '"$LOG_FILE"')'
