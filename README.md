# dotFiles

A comprehensive Wayland-based Linux desktop environment configuration for Arch-based systems (Garuda Linux).

[English](#english) | [繁體中文](#繁體中文)

---

## English

### Overview

This repository contains my personal dotfiles for a cohesive, developer-focused desktop environment built on:

- **Sway** - Tiling Wayland compositor with SwayFX enhancements
- **Tokyo Night** - Consistent color scheme across all applications
- **Vim-centric** - Familiar keybindings throughout the environment
- **Developer tooling** - Full LSP support, formatters, and Claude Code integration

### Screenshots

*Coming soon*

### Features

#### Window Management
- Sway with SwayFX visual enhancements (blur, shadows, rounded corners)
- 10 workspaces across dual monitors
- Vim-style navigation (`$mod+h/j/k/l`)
- Smart workspace creation and navigation
- Gesture support for touchpad users

#### Development Environment
- **Neovim** with lazy.nvim plugin manager
- LSP support for Lua, C/C++, Vim, and more
- Telescope fuzzy finder (`Ctrl+P` files, `Ctrl+G` grep)
- Treesitter syntax highlighting for 13+ languages
- Claude Code AI integration

#### System Monitoring
- **Waybar** status bar with 40+ modules
- **MangoHud** GPU overlay for gaming (165 FPS limit)
- **Bottom** terminal-based resource monitor

#### Applications
| Application | Purpose |
|-------------|---------|
| Foot | GPU-accelerated terminal emulator |
| Fuzzel | Fast application launcher |
| Mako | Notification daemon |
| Yazi | Terminal file manager |
| Swayr | Window switcher |

### Requirements

- Arch Linux or derivatives (tested on Garuda Linux)
- Wayland session
- Sway window manager
- Required packages:
  ```bash
  # Core
  sway swaylock swayidle swaybg waybar mako foot fuzzel

  # Utilities
  grim slurp wl-clipboard cliphist kanshi autotiling

  # Optional
  mangohud bottom neovim yazi wofi
  ```

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Dragonfly911117/dotFiles.git ~/.dotfiles
   ```

2. **Backup existing configs:**
   ```bash
   mkdir -p ~/.config-backup
   cp -r ~/.config/{sway,waybar,nvim,foot,fuzzel,mako} ~/.config-backup/
   ```

3. **Create symlinks:**
   ```bash
   cd ~/.dotfiles

   # Sway
   ln -sf $(pwd)/sway ~/.config/sway

   # Waybar
   ln -sf $(pwd)/waybar ~/.config/waybar

   # Neovim
   ln -sf $(pwd)/nvim ~/.config/nvim

   # Terminal
   ln -sf $(pwd)/foot ~/.config/foot

   # Launcher
   ln -sf $(pwd)/fuzzel ~/.config/fuzzel

   # Notifications
   ln -sf $(pwd)/mako ~/.config/mako

   # Other apps
   ln -sf $(pwd)/MangoHud ~/.config/MangoHud
   ln -sf $(pwd)/bottom ~/.config/bottom
   ln -sf $(pwd)/swayr ~/.config/swayr
   ln -sf $(pwd)/yazi ~/.config/yazi
   ln -sf $(pwd)/wofi ~/.config/wofi
   ```

4. **Start Sway:**
   ```bash
   # From TTY
   sway

   # Or add to your shell profile
   [ "$(tty)" = "/dev/tty1" ] && exec sway
   ```

### Directory Structure

```
dotFiles/
├── MangoHud/           # GPU performance overlay
│   └── MangoHud.conf
├── bottom/             # System resource monitor
│   └── bottom.toml
├── foot/               # Terminal emulator
│   └── foot.ini
├── fuzzel/             # Application launcher
│   └── fuzzel.ini
├── mako/               # Notification daemon
│   └── config
├── nvim/               # Neovim editor
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   └── lazy.lua
│       └── plugins/
│           ├── claude-code.lua
│           ├── lsp.lua
│           ├── neo-tree.lua
│           ├── telescope.lua
│           ├── tokyonight.lua
│           └── treesitter.lua
├── sway/               # Window manager
│   ├── config
│   ├── variables
│   ├── config.d/
│   │   ├── application_defaults
│   │   ├── autostart_applications
│   │   ├── default
│   │   ├── input
│   │   ├── keymap
│   │   ├── output
│   │   ├── theme
│   │   └── workspace
│   ├── scripts/
│   │   ├── advance_workspace.sh
│   │   ├── bluetooth_toggle.sh
│   │   ├── screenshot_display.sh
│   │   ├── screenshot_window.sh
│   │   └── swayfader.py
│   └── swayfx/
├── swayr/              # Window switcher
│   └── config.toml
├── waybar/             # Status bar
│   ├── config
│   └── style.css
├── wofi/               # Alt launcher
│   └── config
└── yazi/               # File manager
    ├── theme.toml
    └── yazi.toml
```

### Keybindings

#### General
| Keybinding | Action |
|------------|--------|
| `$mod + Return` | Open terminal (Foot) |
| `$mod + d` | Application launcher (Fuzzel) |
| `$mod + Shift + q` | Close focused window |
| `$mod + Shift + e` | Exit Sway |
| `$mod + Shift + c` | Reload Sway config |

#### Navigation
| Keybinding | Action |
|------------|--------|
| `$mod + h/j/k/l` | Focus left/down/up/right |
| `$mod + Shift + h/j/k/l` | Move window left/down/up/right |
| `$mod + 1-0` | Switch to workspace 1-10 |
| `$mod + Shift + 1-0` | Move window to workspace 1-10 |

#### Layout
| Keybinding | Action |
|------------|--------|
| `$mod + b` | Split horizontal |
| `$mod + v` | Split vertical |
| `$mod + f` | Toggle fullscreen |
| `$mod + Shift + space` | Toggle floating |
| `$mod + e` | Toggle split layout |

#### Utilities
| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot (selection) |
| `$mod + Print` | Screenshot (window) |
| `XF86Audio*` | Volume/media controls |

### Color Scheme

Tokyo Night with custom purple accent:

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#1a1b26` | Primary background |
| Background Alt | `#24283b` | Secondary background |
| Foreground | `#c0caf5` | Text |
| Primary | `#7aa2f7` | Blue accents |
| Accent | `#8478de` | Custom purple |
| Secondary | `#bb9af7` | Purple accents |
| Selection | `#33467c` | Selections |
| Border | `#565f89` | Active borders |

### Hardware Setup

This configuration is optimized for a dual-monitor setup:

- **Primary (DP-3):** 2560x1440 - Workspaces 1-5
- **Secondary (HDMI-A-1):** 1920x1080 - Workspaces 6-10

Modify `sway/config.d/output` and `sway/config.d/workspace` for your setup.

### Customization

#### Change Theme Colors
1. Update hex values in:
   - `sway/config.d/theme`
   - `waybar/style.css`
   - `foot/foot.ini`
   - `fuzzel/fuzzel.ini`
   - `mako/config`
   - `nvim/lua/plugins/tokyonight.lua`

#### Add Neovim Plugins
1. Create `nvim/lua/plugins/your-plugin.lua`
2. Return lazy.nvim plugin spec
3. Run `:Lazy sync`

#### Add Autostart Applications
Edit `sway/config.d/autostart_applications`:
```bash
exec your-application
```

### Troubleshooting

**Sway won't start:**
```bash
# Check for config errors
sway -d 2>&1 | head -50
```

**Waybar not showing:**
```bash
killall waybar
waybar &
```

**Neovim plugins not loading:**
```bash
nvim --headless "+Lazy! sync" +qa
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### License

This project is open source. Feel free to use, modify, and distribute.

### Acknowledgments

- [Sway](https://swaywm.org/) - Wayland compositor
- [SwayFX](https://github.com/WillPower3309/swayfx) - Visual enhancements
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) - Color scheme
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager

---

## 繁體中文

### 概述

這個儲存庫包含我的個人 dotfiles，用於建立一個基於以下技術的整合開發環境：

- **Sway** - 搭配 SwayFX 視覺增強的 Wayland 平鋪式合成器
- **Tokyo Night** - 所有應用程式統一的配色方案
- **Vim 風格** - 整個環境使用熟悉的快捷鍵
- **開發者工具** - 完整的 LSP 支援、格式化工具和 Claude Code 整合

### 螢幕截圖

*即將推出*

### 功能特色

#### 視窗管理
- Sway 搭配 SwayFX 視覺增強（模糊、陰影、圓角）
- 雙螢幕 10 個工作區
- Vim 風格導航（`$mod+h/j/k/l`）
- 智慧工作區建立與導航
- 觸控板手勢支援

#### 開發環境
- **Neovim** 搭配 lazy.nvim 外掛管理器
- LSP 支援 Lua、C/C++、Vim 等語言
- Telescope 模糊搜尋（`Ctrl+P` 檔案、`Ctrl+G` 搜尋）
- Treesitter 語法高亮支援 13+ 種語言
- Claude Code AI 整合

#### 系統監控
- **Waybar** 狀態列，40+ 個模組
- **MangoHud** GPU 顯示覆蓋層（165 FPS 限制）
- **Bottom** 終端機系統資源監控

#### 應用程式
| 應用程式 | 用途 |
|----------|------|
| Foot | GPU 加速終端機模擬器 |
| Fuzzel | 快速應用程式啟動器 |
| Mako | 通知守護程式 |
| Yazi | 終端機檔案管理器 |
| Swayr | 視窗切換器 |

### 系統需求

- Arch Linux 或其衍生版本（在 Garuda Linux 上測試）
- Wayland 環境
- Sway 視窗管理器
- 必要套件：
  ```bash
  # 核心元件
  sway swaylock swayidle swaybg waybar mako foot fuzzel

  # 工具程式
  grim slurp wl-clipboard cliphist kanshi autotiling

  # 選用元件
  mangohud bottom neovim yazi wofi
  ```

### 安裝方式

1. **複製儲存庫：**
   ```bash
   git clone https://github.com/Dragonfly911117/dotFiles.git ~/.dotfiles
   ```

2. **備份現有設定：**
   ```bash
   mkdir -p ~/.config-backup
   cp -r ~/.config/{sway,waybar,nvim,foot,fuzzel,mako} ~/.config-backup/
   ```

3. **建立符號連結：**
   ```bash
   cd ~/.dotfiles

   # Sway
   ln -sf $(pwd)/sway ~/.config/sway

   # Waybar
   ln -sf $(pwd)/waybar ~/.config/waybar

   # Neovim
   ln -sf $(pwd)/nvim ~/.config/nvim

   # 終端機
   ln -sf $(pwd)/foot ~/.config/foot

   # 啟動器
   ln -sf $(pwd)/fuzzel ~/.config/fuzzel

   # 通知
   ln -sf $(pwd)/mako ~/.config/mako

   # 其他應用程式
   ln -sf $(pwd)/MangoHud ~/.config/MangoHud
   ln -sf $(pwd)/bottom ~/.config/bottom
   ln -sf $(pwd)/swayr ~/.config/swayr
   ln -sf $(pwd)/yazi ~/.config/yazi
   ln -sf $(pwd)/wofi ~/.config/wofi
   ```

4. **啟動 Sway：**
   ```bash
   # 從 TTY 啟動
   sway

   # 或加入 shell 設定檔
   [ "$(tty)" = "/dev/tty1" ] && exec sway
   ```

### 目錄結構

```
dotFiles/
├── MangoHud/           # GPU 效能顯示
│   └── MangoHud.conf
├── bottom/             # 系統資源監控
│   └── bottom.toml
├── foot/               # 終端機模擬器
│   └── foot.ini
├── fuzzel/             # 應用程式啟動器
│   └── fuzzel.ini
├── mako/               # 通知守護程式
│   └── config
├── nvim/               # Neovim 編輯器
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   └── lazy.lua
│       └── plugins/
│           ├── claude-code.lua
│           ├── lsp.lua
│           ├── neo-tree.lua
│           ├── telescope.lua
│           ├── tokyonight.lua
│           └── treesitter.lua
├── sway/               # 視窗管理器
│   ├── config
│   ├── variables
│   ├── config.d/
│   │   ├── application_defaults
│   │   ├── autostart_applications
│   │   ├── default
│   │   ├── input
│   │   ├── keymap
│   │   ├── output
│   │   ├── theme
│   │   └── workspace
│   ├── scripts/
│   │   ├── advance_workspace.sh
│   │   ├── bluetooth_toggle.sh
│   │   ├── screenshot_display.sh
│   │   ├── screenshot_window.sh
│   │   └── swayfader.py
│   └── swayfx/
├── swayr/              # 視窗切換器
│   └── config.toml
├── waybar/             # 狀態列
│   ├── config
│   └── style.css
├── wofi/               # 替代啟動器
│   └── config
└── yazi/               # 檔案管理器
    ├── theme.toml
    └── yazi.toml
```

### 快捷鍵

#### 一般操作
| 快捷鍵 | 動作 |
|--------|------|
| `$mod + Return` | 開啟終端機（Foot）|
| `$mod + d` | 應用程式啟動器（Fuzzel）|
| `$mod + Shift + q` | 關閉目前視窗 |
| `$mod + Shift + e` | 離開 Sway |
| `$mod + Shift + c` | 重新載入 Sway 設定 |

#### 導航
| 快捷鍵 | 動作 |
|--------|------|
| `$mod + h/j/k/l` | 焦點 左/下/上/右 |
| `$mod + Shift + h/j/k/l` | 移動視窗 左/下/上/右 |
| `$mod + 1-0` | 切換到工作區 1-10 |
| `$mod + Shift + 1-0` | 移動視窗到工作區 1-10 |

#### 佈局
| 快捷鍵 | 動作 |
|--------|------|
| `$mod + b` | 水平分割 |
| `$mod + v` | 垂直分割 |
| `$mod + f` | 切換全螢幕 |
| `$mod + Shift + space` | 切換浮動模式 |
| `$mod + e` | 切換分割佈局 |

#### 工具
| 快捷鍵 | 動作 |
|--------|------|
| `Print` | 螢幕截圖（選取區域）|
| `$mod + Print` | 螢幕截圖（目前視窗）|
| `XF86Audio*` | 音量/媒體控制 |

### 配色方案

Tokyo Night 搭配自訂紫色強調色：

| 顏色 | 色碼 | 用途 |
|------|------|------|
| 背景色 | `#1a1b26` | 主要背景 |
| 次要背景 | `#24283b` | 次要背景 |
| 前景色 | `#c0caf5` | 文字 |
| 主色 | `#7aa2f7` | 藍色強調 |
| 強調色 | `#8478de` | 自訂紫色 |
| 次要色 | `#bb9af7` | 紫色強調 |
| 選取色 | `#33467c` | 選取區域 |
| 邊框色 | `#565f89` | 活動邊框 |

### 硬體設定

此設定針對雙螢幕環境最佳化：

- **主螢幕（DP-3）：** 2560x1440 - 工作區 1-5
- **副螢幕（HDMI-A-1）：** 1920x1080 - 工作區 6-10

請根據您的設備修改 `sway/config.d/output` 和 `sway/config.d/workspace`。

### 自訂設定

#### 更改主題顏色
1. 更新以下檔案中的色碼：
   - `sway/config.d/theme`
   - `waybar/style.css`
   - `foot/foot.ini`
   - `fuzzel/fuzzel.ini`
   - `mako/config`
   - `nvim/lua/plugins/tokyonight.lua`

#### 新增 Neovim 外掛
1. 建立 `nvim/lua/plugins/your-plugin.lua`
2. 回傳 lazy.nvim 外掛規格
3. 執行 `:Lazy sync`

#### 新增自動啟動應用程式
編輯 `sway/config.d/autostart_applications`：
```bash
exec your-application
```

### 疑難排解

**Sway 無法啟動：**
```bash
# 檢查設定錯誤
sway -d 2>&1 | head -50
```

**Waybar 未顯示：**
```bash
killall waybar
waybar &
```

**Neovim 外掛未載入：**
```bash
nvim --headless "+Lazy! sync" +qa
```

### 貢獻

1. Fork 此儲存庫
2. 建立功能分支
3. 進行修改
4. 提交 Pull Request

### 授權

本專案為開源軟體，歡迎使用、修改和散布。

### 致謝

- [Sway](https://swaywm.org/) - Wayland 合成器
- [SwayFX](https://github.com/WillPower3309/swayfx) - 視覺增強
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) - 配色方案
- [lazy.nvim](https://github.com/folke/lazy.nvim) - 外掛管理器
