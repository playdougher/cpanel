# cpanel

An interactive command history and execution dashboard using fzf.

## Overview

cpanel provides a split-pane interface to browse your command history and execute tasks asynchronously. The left side displays your history, while the right side shows a live-streaming log of your execution.

## Installation

Run the following commands to compile and install the binary:

```bash
make
make install
```

The binary will be installed to `~/.local/bin/cpanel`. Ensure this directory is in your `$PATH`.

## Usage

You can launch the tool by simply typing `cpanel` in your terminal. For instant access, you can bind it to a shortcut like `Ctrl+P` in your `~/.bashrc`:

```bash
bind -x '"\C-op": cpanel'
```

### Key Bindings

| Key | Action |
|-----|--------|
| **Enter / Double-Click** | Run command in the background |
| **Ctrl+O / Right-Click** | Run command in the foreground |
| **Ctrl+V** | Open full log in `less` (starts at bottom) |

## Development

- `make clean`: Remove build artifacts.
- `make uninstall`: Remove the binary from your system.

