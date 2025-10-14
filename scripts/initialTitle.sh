#!/bin/zsh

raw="$(hyprctl activewindow)"

json="$(echo "$raw" | jq -Rn '
  [ inputs
    | sub("\r$"; "")
    | select(test(":"))
    | capture("^(?<key>[^:]+):[ \t]*(?<value>.*)$")
    | .key |= ltrim
  ]
  | from_entries
')"

title="$(echo "$json" | jq '.initialTitle')"

echo "$title"
