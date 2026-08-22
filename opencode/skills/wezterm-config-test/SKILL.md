---
name: wezterm-config-test
description: Test wezterm configuration for errors by launching wezterm with the config file and capturing output. Use when editing wezterm config files and needing to verify they are valid.
---

# Wezterm Config Test

## Overview

Tests a wezterm configuration file by attempting to launch wezterm with it, capturing any errors from stdout/stderr.

## How It Works

1. Find the wezterm config file (default: `~/.config/wezterm/wezterm.lua`)
2. Launch `wezterm start -- --config-file <path>` with a timeout
3. Capture stdout/stderr output
4. Parse errors and report them with line numbers if possible

## Verification Command

```bash
perl -e 'alarm 3; exec @ARGV' wezterm start -- --config-file /Users/leiwenpeng/.config/wezterm/wezterm.lua 2>&1 || true
```

Note: `perl -e 'alarm 3; exec @ARGV'` provides a 3-second timeout on macOS (which lacks the `timeout` command).

## Error Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `is not a valid.*variant` | Wrong API name | `TogglePaneZoom` should be `TogglePaneZoomState` |
| `is not a valid PaneDirection` | Wrong direction | `Previous` should be `Prev` |
| `attempt to call a nil value` | Function doesn't exist | `wezterm.basename` should be `wezterm.path_basename` |
| `runtime error` | Lua runtime error in callbacks | Check the referenced line number |
| `Configuration Error` | Config-level error | Check the message for guidance |

## Usage

When the user asks to test or verify their wezterm config:

1. Run the verification command above
2. If errors found:
   - Extract the error message and line number
   - Suggest the fix
   - Apply the fix if user approves
3. Re-run to verify fix
4. Report final status

## Common Fixes

| Error | Fix |
|-------|-----|
| `Previous` is not valid PaneDirection | Change to `Prev` |
| `wezterm.basename` is nil | Change to `wezterm.path_basename` |
| `TogglePaneZoom` not valid | Remove or check docs for correct API |
| `ShowWindowManager` not valid | Change to `ShowLauncher` |
