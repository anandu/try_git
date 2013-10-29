#!/bin/bash
# This script will take 1 argument and it checks only the directories list in
# test file ( here /temp/abc.txt ) for the argument string. Tells how many files
# have atleast one appearence of the agrument string.
value=
#IFS=" "
while read line; do
  # Check only whole string, take only single appearance and counts the number.
  n=`grep -w "$1" $line -r | uniq | wc -l`
  value=`expr $value + $n`
  printf "directories in the text file are %s \n" $line
done < /temp/abc.txt
echo "Term $1 appears $value files"
