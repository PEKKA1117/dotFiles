#!/usr/bin/env bash
# 把 ~/.config/bin 裡的腳本以 symlink 掛到 ~/.local/bin
#
# 腳本本體只放在這個 repo,~/.local/bin 只留指向這裡的相對 symlink,
# 所以改 repo 裡的檔案就等於改了 PATH 上的指令,不會有兩份各自漂移。
# 可重複執行:已經指對的會略過;沒有東西的直接建立。
#
# 不會蓋掉的情況(只印警告,要自己處理):
#   - 目標是內容不同的一般檔案   → 先比對差異,確認後刪掉再重跑
#   - 目標是指向別處的 symlink   → 可能是 uv/pipx 裝的同名指令
# 目標是內容相同的一般檔案(搬進 repo 前的舊副本)會直接換成 symlink。
#
# 另外會清掉 ~/.local/bin 裡指向本目錄、但來源已不存在的 symlink(改名或刪除後的殘骸)。
#
# 用法:~/.config/bin/link.sh

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
DEST_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
SELF=$(basename "${BASH_SOURCE[0]}")

mkdir -p "$DEST_DIR"

for src in "$SRC_DIR"/*; do
    name=$(basename "$src")
    # 自己不掛;不可執行的檔案(說明文件之類)也不掛
    [[ $name == "$SELF" || ! -f $src || ! -x $src ]] && continue

    dest=$DEST_DIR/$name
    rel=$(realpath --relative-to="$DEST_DIR" "$src")

    if [[ -L $dest ]]; then
        if [[ $(realpath -m "$dest") == "$src" ]]; then
            continue
        fi
        echo "略過 $name:已是指向 $(readlink "$dest") 的 symlink" >&2
        continue
    elif [[ -e $dest ]]; then
        if ! cmp -s "$src" "$dest"; then
            echo "略過 $name:$dest 是內容不同的一般檔案,請先 diff 確認" >&2
            continue
        fi
        rm -- "$dest"
    fi

    ln -s -- "$rel" "$dest"
    echo "已連結 $name -> $rel"
done

# 清掉指向本目錄但來源已消失的 symlink
for dest in "$DEST_DIR"/*; do
    [[ -L $dest && ! -e $dest ]] || continue
    [[ $(realpath -m "$dest") == "$SRC_DIR"/* ]] || continue
    rm -- "$dest"
    echo "已移除失效連結 $(basename "$dest")"
done
