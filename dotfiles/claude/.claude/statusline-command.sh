#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
if [ -n "$ctx_size" ]; then
  ctx_size_m=$(echo "$ctx_size" | awk '{printf "%.0fK", $1/1000}')
  if [ "$ctx_size" -ge 1000000 ]; then
    ctx_size_m=$(echo "$ctx_size" | awk '{printf "%.0fM", $1/1000000}')
  fi
  model_str="$model (${ctx_size_m} context)"
else
  model_str="$model"
fi

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$used" ] && [ -n "$remaining" ]; then
  ctx_str=$(printf "ctx: %.0f%% used, %.0f%% left" "$used" "$remaining")
else
  ctx_str=""
fi

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
limits_str=""
if [ -n "$five" ] || [ -n "$week" ]; then
  limits_parts=""
  [ -n "$five" ] && limits_parts=$(printf "5h: %.0f%%" "$five")
  if [ -n "$week" ]; then
    week_part=$(printf "7d: %.0f%%" "$week")
    if [ -n "$limits_parts" ]; then
      limits_parts="$limits_parts, $week_part"
    else
      limits_parts="$week_part"
    fi
  fi
  limits_str="limits: $limits_parts"
fi

parts=""
parts="$model_str"
[ -n "$ctx_str" ] && parts="$parts | $ctx_str"
[ -n "$limits_str" ] && parts="$parts | $limits_str"

echo "$parts"
