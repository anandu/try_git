#!/bin/bash
set -e
echo -n "How old are you? "
read age;
if ((30 < age && age < 60)); then
echo "Wow, in $((60-age)) years, you'll be 60!"
else
echo "You are too young or too old to play."
fi
