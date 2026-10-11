#!/bin/bash
# Show the next scratchpad window (or hide the focused one).
# satty windows are resized one resolution tier below the current monitor
# (FHD on 4K, HD+ on QHD, HD on FHD) and centered each time they are shown.

swaymsg -q scratchpad show

read -r out_w < <(swaymsg -t get_tree | jq -r '
    .nodes[] | select(.type == "output") as $o
    | $o | .. | objects
    | select(.focused? and .app_id? == "com.gabm.satty")
    | $o.rect.width')

[ -z "$out_w" ] && exit 0

if   [ "$out_w" -ge 3840 ]; then size="1920 px height 1080"
elif [ "$out_w" -ge 2560 ]; then size="1600 px height 900"
elif [ "$out_w" -ge 1920 ]; then size="1280 px height 720"
else                             size="$((out_w / 2)) px height $((out_w * 9 / 32))"
fi

swaymsg -q "[con_id=__focused__] resize set width $size px, move position center"
