#!/bin/bash

# SETTING A VARIABLE
 greeting="Hello World"

# SETTING A GLOBAL/ENVIRONMENT VARIABLE
 export blogname="andycast"

# ASSIGN OUTPUT OF SUBSHELL TO VARIABLE
 filenames=$(ls -ltr) # note that subshell inherits all environment variables from parent shell
 no_of_files=`ls -ltr | wc -l`

# HOW TO CREATE MULTIPLE LINE COMMENT
<<COMMENT
 The previous line begins a comment block, this is also known as HERE DOCUMENT
 Here's another comment
 The following line ends the comment block
COMMENT

# PERFORM ARITHMETIC CALCULATION
 var1=45
 var2=30
 echo $[ $var1 + $var2 ]
 (( sum=$var1 + $var2 ))
 echo $sum

# IF STATEMENT
if [ $[ $var1 + $var2 ] -gt 70 ];then
  echo "sum is greater than 70"
elif [ $[ $var1 + $var2 ] -lt 70 ];then
  echo "sum is less than 70"
else
  echo "unknown"
fi

# WHILE STATEMENT
 var1=10
 while [ $var1 -gt 0 ];do
   echo "while \$var1 is greater than 0, keep running … "
   var1=$[ $var1 - 1 ]
 done

# UNTIL STATEMENT
 var1=0
 until [ $var1 -gt 10 ];do
   echo "until \$var1 is greater than 30, keep running …"
   var1=$[ $var1 + 1 ]
 done

# FOR STATEMENT
 for arg in $@;do
   echo $arg
 done

# CASE STATEMENT
 var1=1
 case $var1 in
 1) echo "hello world"
  echo "Bash tutorials";;
 2) echo "wrong option";;
 3) echo "guess again";;
 *) echo "Default option";;
 esac
