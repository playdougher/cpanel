# Design: Execute Current Input Command in `cpanel.sh`

- **Date**: 2026-03-28
- **Topic**: Execute Current Input
- **Author**: Gemini CLI

## Overview
Currently, `cpanel.sh` only allows executing commands that already exist in the shell history. Users want to be able to execute the command they have just typed into the `fzf` search box, even if it's not in the history.

## Goals
- Add a shortcut to execute the current query (input) in `fzf`.
- The execution should run in the background, similar to the `Enter` behavior for history items.
- The command should be added to the history file and logged to the panel.

## Architecture & Components

### `fzf` Placeholders
- Use `{q}` which represents the current query string in `fzf`.

### New Variable: `RUN_QUERY_BG_CMD`
A new variable will be defined to handle the execution of the query. It will follow the pattern of `RUN_BG_CMD` but use `{q}` instead of `{}`.

```bash
RUN_QUERY_BG_CMD="$KILL_OLD; \
            echo {q} >> '$HISTORY_FILE'; \
            echo -e \"\\n[Background Execution]: \"{q} >> $LOG_FILE; \
            SYSTEMD_PAGER='' script -q -c \"{q}\" /dev/null >> $LOG_FILE 2>&1 & echo \$! > $PID_FILE"
```

### Bindings
- **Shortcut**: `Alt-Enter`
- **Action**: `execute-silent($RUN_QUERY_BG_CMD) + reload($RELOAD_CMD)`
- **Header**: Update header to inform the user about the new shortcut.

## Data Flow
1. User types a command in `fzf`.
2. User presses `Alt-Enter`.
3. `fzf` replaces `{q}` in `RUN_QUERY_BG_CMD` with the literal text of the query.
4. `RUN_QUERY_BG_CMD` is executed by `fzf` using `sh -c`.
5. The command is appended to `$HISTORY_FILE`.
6. A log entry is added to `$LOG_FILE`.
7. `script` runs the command and pipes its output to `$LOG_FILE`.
8. The PID is stored for potential killing on next execution.
9. `fzf` reloads the history, now including the newly executed command.

## Testing Strategy
1. **Empty Query**: Ensure `Alt-Enter` with an empty query does nothing or doesn't crash (it should just try to execute an empty string which is a no-op).
2. **New Command**: Type a command not in history (e.g., `date`), press `Alt-Enter`, and check if it appears in the log and history.
3. **Escaping**: Test commands with spaces and special characters.
