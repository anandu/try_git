#!/bin/bash
#--------------------------------------------------------------------
# @(#) ccc.sh - (simple) Code convetion checker 
#--------------------------------------------------------------------
#
usage() {
  echo "USAGE: $0 dir_name"
}

if [ -z "$1" ]; then
  usage
fi
echo "Do you want to skip anything from this test, if yes enter it now in comma"
echo "seperated form. If no, press enter to continue"
read skip
echo "###############################"
echo "Comment is not started with capital letter at:"
grep -rE "^# [a-z]" "$1" | grep -ivnE "metadata|rightscale" 
echo "###############################"
echo "log has not 2 spaces/first letter is not capital at:"
grep -rv "log \"  [A-Z]" "$1" | grep -iv "metadata" | grep -n --color=auto "log \""
echo "###############################"
echo "No space after comma,colon or semi colon"
grep -r "[\,\:\;]" "$1" | grep -v "[\,\:\;]$" | grep -v "[\,\:\;] " | grep --color=auto "[\,\:\;]"
echo "###############################"
echo "String interpolation is not require :"
grep -ir "#" "$1"  | grep -vE "raise|log|right_link_tag" | grep --color=auto node
echo "###############################"
echo "There should spaces around things inside ERB tags."
grep -r "@" "$1/templates/default/" | grep --color=auto -E "=@|[a-z]%" 
echo "###############################"
echo "Checking Syntax errors, in newly added or modified files"
against=`git rev-parse --verify HEAD`
for i in `git diff --cached --name-only $against | cut -d/ -f2-`; do ruby -c $i ;done
<<TODO
7. There should be no extra spaces for an array.
Use spaces around operators, after commas, colons and semicolons, around { and before } in case of blocks.
  space after comma , not before   grep -r "," . | grep -viE "json|,$|copyright|agreement" | grep ","
      grep -E "," . -r | grep -vE "json|erb|,$" | grep -v ", "
TODO
