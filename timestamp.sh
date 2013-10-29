#!/bin/bash
#Adds a timestamp to the outputs of a program
echo "Usage:ping ip(/any program) | ./timestamp.sh"
while read line; do
  clock=$(date '+(%H:%M:%S)')
  echo "$clock $line"
done

# Another version
 
# DATECMD='date +%H:%M:%S'
  
#  while read line; do
#    echo -e "$($DATECMD) $line"
#  done
