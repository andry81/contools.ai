#!/usr/bin/env bash

# markdown formatter for the `Qwen3.8-Max` AI thinking output

i=0

while IFS=$'\r\n' read line; do
  if (( ! (i % 4) )); then
    echo $'\n'"* $line"
  else
    echo "  > $line"
  fi
  (( i++ ))
done < in.txt > out.txt
