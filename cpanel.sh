#!/bin/bash

# Force terminal width to prevent background truncation at 80 columns
export COLUMNS=512

LOG_FILE=$(mktemp)
PID_FILE=$(mktemp) 

KILL_OLD="pid=\$(cat $PID_FILE 2>/dev/null); if [ -n \"\$pid\" ]; then pkill -9 -P \"\$pid\" 2>/dev/null; kill -9 \"\$pid\" 2>/dev/null; fi"
trap "$KILL_OLD; rm -f $LOG_FILE $PID_FILE" EXIT

echo "=== Execution Log === (Press Ctrl+L to clear)" > "$LOG_FILE"

HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
if [ ! -f "$HISTORY_FILE" ]; then 
  HISTORY_FILE="$HOME/.zsh_history"
fi

RELOAD_CMD="\tail -n 5000 '$HISTORY_FILE' | sed -E 's/^: [0-9]+:[0-9]+;//' | sed '/^#/{d}' | tac | awk '!seen[\$0]++' | head -n 2000"

RUN_BG_CMD="$KILL_OLD; \
            echo {} >> '$HISTORY_FILE'; \
            echo -e \"\\n[Background Execution]: \"{} >> $LOG_FILE; \
            SYSTEMD_PAGER='' script -q -c "{}" /dev/null >> $LOG_FILE 2>&1 & echo \$! > $PID_FILE"

RUN_FG_CMD="echo {} >> '$HISTORY_FILE'; SYSTEMD_PAGER='' script -q -c "{}" /dev/null"

RUN_QUERY_BG_CMD="$KILL_OLD; \
            echo {q} >> '$HISTORY_FILE'; \
            echo -e \"\\n[Background Execution]: \"{q} >> $LOG_FILE; \
            SYSTEMD_PAGER='' script -q -c {q} /dev/null >> $LOG_FILE 2>&1 & echo \$! > $PID_FILE"

eval "$RELOAD_CMD" | fzf \
  --ansi \
  --tiebreak=index \
  --layout=reverse \
  --header="[Enter/Dbl-Click] Background | [Alt-Enter] Execute Input | [Right-Click/Ctrl+O] Foreground | [Ctrl+V] Fullscreen(less) | [Ctrl+L] Clear" \
  --preview="\tail -n 2000 $LOG_FILE" \
  --preview-window="right:60%:wrap:follow" \
  --bind='double-click:execute-silent('"$RUN_BG_CMD"')+reload('"$RELOAD_CMD"')' \
  --bind='enter:execute-silent('"$RUN_BG_CMD"')+reload('"$RELOAD_CMD"')' \
  --bind='alt-enter:execute-silent('"$RUN_QUERY_BG_CMD"')+reload('"$RELOAD_CMD"')' \
  --bind='right-click:execute('"$RUN_FG_CMD"')+reload('"$RELOAD_CMD"')' \
  --bind='alt-j:jump' \
  --bind='ctrl-o:execute('"$RUN_FG_CMD"')+reload('"$RELOAD_CMD"')' \
  --bind='ctrl-v:execute(less -RX +G '"$LOG_FILE"')' \
  --bind='ctrl-l:execute-silent(echo "=== Execution Log === (Press Ctrl+L to clear)" > '"$LOG_FILE"')'
