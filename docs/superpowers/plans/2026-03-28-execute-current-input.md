# Execute Current Input in `cpanel.sh` Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a shortcut (`Alt-Enter`) to execute the current query/input in the `fzf` panel of `cpanel.sh`.

**Architecture:** Use `fzf`'s `{q}` placeholder to access the current query string and execute it in the background using a pattern similar to the existing `RUN_BG_CMD`.

**Tech Stack:** Bash, fzf

---

### Task 1: Define `RUN_QUERY_BG_CMD` in `cpanel.sh`

**Files:**
- Modify: `cpanel.sh`

- [ ] **Step 1: Define the new execution variable**
    Add `RUN_QUERY_BG_CMD` after `RUN_FG_CMD`. It should follow the background execution pattern but use `{q}` instead of `{}`.

```bash
RUN_QUERY_BG_CMD="$KILL_OLD; \
            echo {q} >> '$HISTORY_FILE'; \
            echo -e \"\\n[Background Execution]: \"{q} >> $LOG_FILE; \
            SYSTEMD_PAGER='' script -q -c \"{q}\" /dev/null >> $LOG_FILE 2>&1 & echo \$! > $PID_FILE"
```

- [ ] **Step 2: Commit**

```bash
git add cpanel.sh
git commit -m "feat: define RUN_QUERY_BG_CMD for query execution"
```

---

### Task 2: Add Binding and Update Header

**Files:**
- Modify: `cpanel.sh`

- [ ] **Step 1: Add `alt-enter` binding to `fzf`**
    Add the following line to the `fzf` call's `--bind` section:
    `--bind='alt-enter:execute-silent('"$RUN_QUERY_BG_CMD"')+reload('"$RELOAD_CMD"')'`

- [ ] **Step 2: Update the `fzf` header**
    Add `| [Alt-Enter] Execute Input` to the `--header` string.

- [ ] **Step 3: Commit**

```bash
git add cpanel.sh
git commit -m "feat: add Alt-Enter binding for current input execution"
```

---

### Task 3: Update Executable and Verify

**Files:**
- Modify: `cpanel` (via `make`)

- [ ] **Step 1: Run `make` to update the `cpanel` executable**
    Run: `make`
    Expected: `cpanel` file is updated.

- [ ] **Step 2: Manual Verification**
    Run: `./cpanel.sh`
    1. Type a new command (e.g., `date`).
    2. Press `Alt-Enter`.
    3. Check if the output appears in the right preview pane (log).
    4. Check if `date` now appears in the history list (after reload).

- [ ] **Step 3: Final Commit**

```bash
git add cpanel
git commit -m "build: update cpanel executable"
```
