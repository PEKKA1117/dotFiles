# CLAUDE.md - AI Assistant Guidelines for dotFiles Repository

This document provides comprehensive guidance for AI assistants working with this dotFiles repository.

## Repository Overview

This is a **Wayland-based Linux desktop environment configuration repository** for an Arch-based system (Garuda Linux). It provides a cohesive, developer-focused setup with consistent theming throughout.

**Key Characteristics:**
- Wayland-first (Sway window manager with SwayFX enhancements)
- Tokyo Night color scheme with custom purple accent (`#8478de`)
- Vim-centric keybindings across applications
- Developer tooling with LSP, formatters, and Claude Code integration
- Gaming/multimedia ready with MangoHud overlay and Steam integration

## Directory Structure

```
dotFiles/
├── MangoHud/          # GPU/system performance overlay configuration
├── bottom/            # Terminal system resource monitor (btm)
├── foot/              # GPU-accelerated Wayland terminal emulator
├── fuzzel/            # Wayland application launcher/menu
├── mako/              # Wayland notification daemon
├── nvim/              # Neovim editor with plugins (Lua config)
├── sway/              # Sway window manager (main desktop config)
│   ├── config.d/      # Modular config files (keymap, theme, workspace, etc.)
│   ├── scripts/       # Automation scripts (bash/python)
│   └── swayfx/        # Visual enhancement settings
├── swayr/             # Sway window switcher utility
├── waybar/            # Status bar with 40+ modules
├── wofi/              # Alternative application launcher
└── yazi/              # Terminal file manager
```

## Application Configurations

### Sway (Window Manager)
**Location:** `sway/`

Primary window manager with modular configuration:
- `config` - Main entry point, sources variables and config.d files
- `variables` - Environment variables (terminal=footclient, browser, editor, menu)
- `config.d/keymap` - Keybindings for launchers, screenshots, resizing
- `config.d/workspace` - 10 workspaces bound to dual monitors
- `config.d/output` - Display setup (DP-3: 2560x1440, HDMI-A-1: 1920x1080)
- `config.d/application_defaults` - Floating rules, workspace assignments
- `config.d/autostart_applications` - Startup services and apps

**Key Variables:**
```bash
$mod = Mod4 (Super/Win key)
$term = footclient
$menu = nwg-drawer
$launcher = wofi --show drun
```

### Neovim (Editor)
**Location:** `nvim/`

Lua-based configuration with lazy.nvim plugin manager:
- `init.lua` - Entry point (2-space tabs, line numbers, Tokyo Night theme)
- `lua/plugins/` - Individual plugin configurations:
  - `lsp.lua` - Mason LSP setup (Lua, Vim, Clang servers)
  - `telescope.lua` - Fuzzy finder (Ctrl+P files, Ctrl+G grep, Ctrl+B buffers)
  - `neo-tree.lua` - File explorer with git integration
  - `treesitter.lua` - Syntax highlighting (13 languages)
  - `none-ls.lua` - Formatters (stylua, clang-format, ESLint)
  - `claude-code.lua` - Claude Code AI integration
  - `lua-line.lua` - Status line (Lualine with palenight theme)
  - `mdRender.lua` - Markdown rendering
  - `toykonight.lua` - Tokyo Night theme configuration (note: filename has typo)

### Waybar (Status Bar)
**Location:** `waybar/`

Comprehensive status bar with modules for:
- System metrics (CPU, memory, disk, temperature)
- Network/bandwidth monitoring
- Audio controls and media player
- Battery, Bluetooth, keyboard layout
- Package updates (Pacman), Claude AI usage
- Power controls

### Other Applications

| Application | Location | Purpose |
|-------------|----------|---------|
| Foot | `foot/foot.ini` | Terminal emulator (Tokyo Night theme, 0.9 opacity) |
| Fuzzel | `fuzzel/fuzzel.ini` | Application launcher (dmenu mode) |
| Mako | `mako/config` | Notification daemon |
| MangoHud | `MangoHud/MangoHud.conf` | GPU overlay for gaming (165 FPS limit) |
| Bottom | `bottom/bottom.toml` | System resource monitor |
| Swayr | `swayr/config.toml` | Window switcher using fuzzel |
| Yazi | `yazi/` | Terminal file manager |
| Wofi | `wofi/config` | Alternative launcher |

## Key Conventions

### Theming
**All applications use Tokyo Night color scheme:**
```
Background:    #1a1b26 (dark) / #24283b (lighter)
Foreground:    #c0caf5
Primary:       #7aa2f7 (blue)
Accent:        #8478de (custom purple)
Secondary:     #bb9af7 (purple)
Selection:     #33467c
Border active: #565f89
```

### Keybindings (Sway)
Common patterns across the configuration:
- `$mod+Return` - Terminal
- `$mod+d` - Application launcher (nwg-drawer)
- `$mod+Shift+q` - Close window
- `$mod+h/j/k/l` - Vim-style focus navigation
- `$mod+Shift+h/j/k/l` - Move windows
- `$mod+1-0` - Switch workspaces
- `$mod+Shift+1-0` - Move window to workspace
- `Print` - Screenshot

### File Naming
- Sway configs use plain text files without extensions
- Neovim plugins use `*.lua` in `lua/plugins/`
- Shell scripts use `.sh` extension
- Config files follow application conventions (`.ini`, `.toml`, `.conf`)

### Code Style
- Shell scripts: POSIX-compatible bash
- Lua (Neovim): 2-space indentation
- Config files: Follow upstream formatting conventions

## Scripts and Automation

**Location:** `sway/scripts/`

| Script | Purpose |
|--------|---------|
| `advance_workspace.sh` | Smart workspace navigation (creates new if needed) |
| `bluetooth_toggle.sh` | Toggle Bluetooth on/off |
| `screenshot_window.sh` | Capture focused window (grim + slurp) |
| `screenshot_display.sh` | Capture full display or selection |
| `swayfader.py` | Window transparency animations (i3ipc) |
| `hidpi_1.5.sh` | HiDPI scaling adjustment |
| `import-gsettings` | GTK settings importer |

## Development Workflows

### Adding a New Application Config
1. Create directory at repository root: `app_name/`
2. Copy config files maintaining original structure
3. Apply Tokyo Night theming if applicable
4. Update this CLAUDE.md if significant

### Modifying Sway Configuration
1. Identify appropriate file in `sway/config.d/`
2. Follow existing patterns for keybindings, formatting
3. Test with `swaymsg reload` after changes

### Adding Neovim Plugins
1. Create `nvim/lua/plugins/plugin_name.lua`
2. Return plugin specification table for lazy.nvim
3. Run `:Lazy sync` to install

### Testing Changes
- Sway: `swaymsg reload` or restart session
- Waybar: `killall waybar && waybar &`
- Neovim: Restart or `:source %`
- Foot: Restart terminal

## Hardware Context

**Dual Monitor Setup:**
- Primary: DP-3 @ 2560x1440
- Secondary: HDMI-A-1 @ 1920x1080

**Workspace Distribution:**
- DP-3 (primary): Workspaces 1, 3, 5
- HDMI-A-1 (secondary): Workspaces 2, 4, 8, 9, 10
- Workspaces 6, 7: No explicit output assignment (default behavior)

## Guidelines for AI Assistants

### When Modifying Configs
1. **Preserve theming consistency** - Use Tokyo Night colors
2. **Follow existing patterns** - Check similar configs for style
3. **Test syntax** - Many configs have strict formatting
4. **Avoid breaking keybindings** - Check for conflicts

### When Adding Features
1. **Check existing implementations** - May already exist in config.d
2. **Use modular approach** - Split into appropriate config.d file
3. **Document significant changes** - Update relevant sections

### Common Pitfalls
- Sway config uses `$mod` not `Mod4` directly
- Waybar config is JSON but file has no extension
- Neovim uses lazy.nvim plugin spec format
- Foot uses INI format with specific section names

### Sensitive Files (in .gitignore)
The following are explicitly excluded and should never be committed:
- SSH keys and GitHub tokens
- Browser data (Chromium, Firefox, Brave, Vivaldi)
- 1Password data
- Discord key storage
- Application caches

## Quick Reference

### Common Tasks
| Task | Location | File |
|------|----------|------|
| Add keybinding | `sway/config.d/` | `keymap` or `default` |
| Change theme colors | Multiple | Update hex values |
| Add autostart app | `sway/config.d/` | `autostart_applications` |
| Add Neovim plugin | `nvim/lua/plugins/` | Create new `.lua` file |
| Modify status bar | `waybar/` | `config` and `style.css` |
| Change terminal font | `foot/` | `foot.ini` |

### File Locations by Type
- **Keybindings:** `sway/config.d/keymap`, `sway/config.d/default`
- **Appearance:** `sway/config.d/theme`, `*/style.css`, color sections
- **Startup:** `sway/config.d/autostart_applications`
- **Display:** `sway/config.d/output`
- **Workspaces:** `sway/config.d/workspace`
