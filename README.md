<p align="center">
  <img src="logo_wo_bg.png" width="200" alt="dev-config logo">
</p>

<h1 align="center">dev-config</h1>

<p align="center">
  Personal development environment for Arch Linux with <a href="https://github.com/basecamp/omarchy">Omarchy</a> (Hyprland)
</p>

---

## Overview

A complete dotfiles setup managed with [GNU Stow](https://www.gnu.org/software/stow/), themed with **Catppuccin Mocha** across the entire stack:

- **Shell**: Fish + Starship prompt + Atuin history
- **Editor**: NeoVim (LazyVim)
- **Terminal**: Ghostty
- **Multiplexer**: Tmux + Tmuxinator
- **File manager**: Yazi
- **Window manager**: Hyprland (via Omarchy)
- **Dev infra**: Docker-based Odoo development environment

## Stow Packages

| Package | Description |
|---------|-------------|
| `atuin` | Shell history sync and search |
| `catppuccin` | Catppuccin Mocha theme files (eza, fzf, lazygit) |
| `discord` | Discord desktop settings |
| `fish` | Fish shell config, custom functions (`co`, `oe`, `osh`, `ide`), completions |
| `ghostty` | Ghostty terminal (Catppuccin Mocha, JetBrains Mono, transparency) |
| `git` | Git config and global gitignore (Odoo workflow aliases, split-diffs pager) |
| `hypr` | Hyprland WM overrides (keybindings, input, lock screen, mic mute fix) |
| `klog` | [klog](https://klog.jotaen.net) time-tracking helper scripts (waybar clock-in/out, 7h36/day) |
| `nvim` | NeoVim with LazyVim (LSP, DAP Python, Claude Code, Diffview, git permalink) |
| `starship` | Starship prompt with Catppuccin Mocha palette |
| `tmux` | Tmux config (C-s prefix, vim-tmux-navigator, Catppuccin) |
| `tmuxinator` | Tmuxinator layout for Odoo development |
| `waybar` | Waybar status bar (omarchy overrides, klog time-tracking module) |
| `yazi` | Yazi file manager with Catppuccin Mocha flavor and git plugin |

## Prerequisites

Arch Linux with [Omarchy](https://github.com/basecamp/omarchy) desktop environment.

Required packages:

```
stow fish neovim ghostty tmux starship yazi atuin zoxide eza fzf
ripgrep fd git-split-diffs lazygit tig docker lazydocker
```

## Installation

```bash
git clone <repo-url> ~/src/dev-config
cd ~/src/dev-config/dotfiles

# Stow all packages
stow -v --target=$HOME atuin catppuccin discord fish ghostty git hypr klog nvim starship tmux tmuxinator waybar yazi

# Or stow individually
stow -v --target=$HOME nvim
```

> **Note:** Stow creates symlinks. Existing files will cause conflicts — use `stow --adopt` to pull existing files into the repo first.

### Post-install setup

```bash
# Store Gemini API key in GNOME Keyring (used by NeoVim CodeCompanion)
secret-tool store --label="Gemini API Key" unique "gemini-api-key"

# Install Yazi Catppuccin flavor
ya pkg add yazi-rs/flavors:catppuccin-mocha

# Install Tmux plugins (inside tmux, press prefix + I)
```

## Odoo Development

### Git remote setup

```bash
cd /path/to/odoo
git remote add dev git@github.com:odoo-dev/odoo.git
git remote set-url --push origin you_should_not_push_on_this_repository

cd /path/to/enterprise
git remote add dev git@github.com:odoo-dev/enterprise.git
git remote set-url --push origin you_should_not_push_on_this_repository

cd /path/to/design-themes
git remote add dev git@github.com:odoo-dev/design-themes.git
git remote set-url --push origin you_should_not_push_on_this_repository
```

### Docker infrastructure

The `dockerFiles/` directory contains:
- `docker-compose.yml` — PostgreSQL + Nginx (global services)
- `nginx.conf` — Reverse proxy for Odoo containers
- `images/` — Dockerfiles for multiple distros (bookworm, jammy, noble, trixie) with VNC variants

Odoo containers are created dynamically by the `oe` fish function, not by docker-compose.

### Fish functions

- `oe` — Launch Odoo in Docker with various options (enterprise, debug, shell, tests, upgrade)
- `osh` — Restore Odoo SH database dumps (zip/gzip)
- `co` — Git checkout helper for Odoo branches
- `ide` — Launch tmuxinator Odoo layout

## Helper Scripts

- `fix_ssh_passphrase.sh` — Store SSH key passphrase in GNOME Keyring for auto-unlock
- `setup_mute_fix.sh` — Sync ThinkPad mic mute LED with actual mute state (Hyprland)

## Time Tracking (klog)

Work hours are tracked with [klog](https://klog.jotaen.net) (`yay -S klog-time-tracker-bin`) and surfaced in waybar:

- **Log file**: `~/klog/work.klg` (plain text, `klog bookmarks set ~/klog/work.klg default`)
- **Target**: 7h36/day on weekdays — auto-applied on first clock-in of the day via `--should 7h36m`
- **Clicking the waybar module**: left-click toggles start/stop, right-click opens the log in NeoVim
- **Display**: just the current day's tracked time; tooltip shows `Today: X:XX / 7:36 (diff ±H:MM)` and rolling `Bank: ±H:MM` across all records
- **Scripts**: `~/.config/klog/klog-toggle` (clock in/out, signals waybar via `SIGRTMIN+11`) and `~/.config/klog/klog-waybar` (JSON output)

## Omarchy Notes

This repo tracks **personal overrides** on top of [Omarchy](https://github.com/basecamp/omarchy)'s default configs. The `hypr` stow package contains only files with custom modifications:

- `bindings.conf` — Custom keybindings (tmux, opencode, mic mute fix with LED sync)
- `input.conf` — US altgr-intl keyboard, natural scroll, custom repeat rate
- `hyprlock.conf` — Fingerprint unlock, custom placeholder

Files identical to Omarchy defaults (autostart, hypridle, hyprsunset, xdph) are **not tracked** — Omarchy manages them. `monitors.conf` is machine-specific and must be created manually per device.

Capslock remap to Control (held) / Esc (pressed): see [omarchy#1383](https://github.com/basecamp/omarchy/discussions/1383)
