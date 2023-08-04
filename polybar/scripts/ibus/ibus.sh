#!/bin/bash

input=$(ibus engine)

if [ "$input" = "xkb:us::eng" ]; then
  output="US"
elif [ "$input" = "mozc-jp" ]; then
  output="JA"
else
  output="Unkown"
fi

echo $output
