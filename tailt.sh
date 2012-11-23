#!/bin/bash
# This script helps to monitor tests
cd ~/virtualmonkey
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
grep -v "TEST" log/*/*/*/*/$latestlog
echo "Continuing with the log..."
tailf log/*/*/*/*/$latestlog
