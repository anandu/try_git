#!/bin/bash
# This script helps to monitor tests
cd ~/virtualmonkey
latestlog=
latestrestlog=

latestlog=`ls -tr1 log/*/*/*/* | egrep -v "(stderr|rest|index|total)" | tail -n 1`
latestrestlog=`ls -tr1 log/*/*/*/* | egrep  rest | tail -n 1`

# Finds ip address of currently launched servers
for i in `grep "got IP" log/*/*/*/*/$latestrestlog | awk -F: {'print $NF'}`
  do
  x=`expr $x + 1`
  echo "s_$x is $i"
done

# Completed tests
echo "Tests completed..."
echo "******************"
grep ": TEST" log/*/*/*/*/$latestlog | awk  {'print $6'}
echo "******************"
echo "Continuing with the log..."

ls log/*/*/*/*/$latestlog
read -sn 1 -p "Press any key to continue..."

tailf log/*/*/*/*/$latestlog
