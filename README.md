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
| `agent-sandbox` | Bubblewrap-sandboxed Claude Code (`~/.local/libexec/agent-sandbox/claude`) + a `PATH` entry (`~/.config/environment.d/`) so it wins over the raw binary for every launcher, not just fish |
| `atuin` | Shell history sync and search |
| `catppuccin` | Catppuccin Mocha theme files (eza, fzf, lazygit) |
| `discord` | Discord desktop settings |
| `fish` | Fish shell config, custom functions (`co`, `oe`, `osh`, `ide`), completions |
| `ghostinator` | Saved `ghostinator` layouts (tmuxinator-for-Ghostty, `~/src/ghostinator`) |
| `ghostty` | Ghostty terminal (Catppuccin Mocha, JetBrains Mono, transparency) |
| `git` | Git config and global gitignore (Odoo workflow aliases, split-diffs pager) |
| `goo` | goo's live config.json (repos, workspaces, settings) — grows over time, commit to snapshot |
| `hypr` | Hyprland WM overrides (input, monitors, one window rule) |
| `mise` | Global mise tool versions (`~/.config/mise/config.toml`) — codex, gemini, gh, node |
| `nvim` | NeoVim with LazyVim (LSP, DAP Python, Claude Code, Diffview, git permalink) |
| `omarchy` | Omarchy shell overrides (status bar layout via `shell.json`) |
| `starship` | Starship prompt with Catppuccin Mocha palette |
| `tmux` | Tmux config (C-s prefix, vim-tmux-navigator, Catppuccin) |
| `tmuxinator` | Tmuxinator layout for Odoo development |
| `yazi` | Yazi file manager with Catppuccin Mocha flavor and git plugin |

## Prerequisites

Arch Linux with [Omarchy](https://github.com/basecamp/omarchy) desktop environment (Quattro/4.0+, Lua-based Hyprland config and Quickshell-based bar).

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
stow -v --target=$HOME agent-sandbox atuin catppuccin discord fish ghostinator ghostty git hypr mise nvim omarchy starship tmux tmuxinator yazi

# Or stow individually
stow -v --target=$HOME nvim
```

> **Note:** Stow creates symlinks. Existing files will cause conflicts — a fresh Omarchy install
> writes real files into `~/.config/hypr/*.lua` and `~/.config/omarchy/shell.json`, so remove
> those first (or use `stow --adopt` to pull them into the repo instead of overwriting them).
>
> **Note:** the `hypr` package tracks `hyprland.lua`, `input.lua`, `monitors.lua`,
> `looknfeel.lua`, `bindings.lua`, and `autostart.lua`. `hyprsunset.conf` and `xdph.conf` are
> the only ones left as real, untracked files managed by Omarchy. If `~/.config/hypr` doesn't
> already exist as a real directory before running `stow`, Stow will symlink the whole directory
> as a single unit instead of individual files, and anything later written into it (e.g. by
> `omarchy refresh config`) will land inside this repo instead of on disk. Make sure
> `~/.config/hypr` exists as a real directory (a fresh Omarchy install creates it) before
> stowing `hypr`.
>
> **Note:** `agent-sandbox` expects Claude Code already installed natively at `~/.local/bin/claude`
> (`curl -fsSL https://claude.ai/install.sh | bash`) — it wraps that binary, it doesn't install
> one. The `PATH` entry in `~/.config/environment.d/` is only read by systemd at user-session
> start, so log out/in (or reboot) after stowing it for `PATH` ordering to actually change.

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
- `images/` — Dockerfiles per Ubuntu distro (jammy, noble)

Odoo containers are created dynamically by the `oe` fish function, not by docker-compose.

### Fish functions

- `oe` — Launch Odoo in Docker with various options (enterprise, debug, shell, tests, upgrade)
- `osh` — Restore Odoo SH database dumps (zip/gzip)
- `co` — Git checkout helper for Odoo branches
- `ide` — Launch tmuxinator Odoo layout

## Helper Scripts

- `fix_ssh_passphrase.sh` — Store SSH key passphrase in GNOME Keyring for auto-unlock

## Omarchy Notes

This repo tracks **personal overrides** on top of [Omarchy](https://github.com/basecamp/omarchy)'s default configs (Quattro/4.0+: Hyprland config is Lua under `~/.config/hypr/`, loaded after Omarchy's own defaults, and the status bar is a Quickshell plugin configured via `~/.config/omarchy/shell.json`).

The `hypr` stow package contains:

- `input.lua` — US altgr-intl keyboard, natural scroll, custom repeat rate, Ghostty scroll tuning
- `hyprland.lua` — Omarchy's stock template plus one window rule (XWayland Chrome from the Odoo docker container)
- `monitors.lua` — machine-specific, must be recreated per device
- `looknfeel.lua` — niri-like layout: `general.layout = "scrolling"` (Hyprland's native scrolling/column layout, always on)
- `bindings.lua` — SUPER+TAB toggles the scrolloverview plugin's niri-style overview; "Next workspace" moved to SUPER+PAGE_DOWN to make room
- `autostart.lua` — `hyprpm reload -n` on login, to load the scrolloverview plugin

The `omarchy` package's `shell.json` lays out the status bar (menu, workspaces, indicators, media/mpris, clock, weather, system update, tray, agents, bluetooth, network, audio, monitor, power) using Omarchy's first-party Quickshell widgets — no CSS needed, colors follow the active theme.

Capslock remap to Control (held) / Esc (pressed) is done via `keyd` (see [omarchy#1383](https://github.com/basecamp/omarchy/discussions/1383)), not part of this stow repo since it's a root-level system config:

```
# /etc/keyd/default.conf
[ids]
*
[main]
capslock = overload(control, esc)
```

then `sudo systemctl enable --now keyd`.
