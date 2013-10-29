#!/bin/bash
IFS=,  read -a ARRAY1 <<< "abc,xyz,pqr"
for i in "${ARRAY1[@]}"
do
  echo $i | sed 's/^[ \t]*//'
  #tmp=`echo $i | sed 's/^[ \t]*//'`
  #/usr/bin/python $tmp
done

# Lists name of the nodes only with signed certifacates. Removes doublequotes.
#node=$(puppet cert list --all | awk '/^+/ {gsub(/"/,"",$2); print $2}')
#for i in $nodes; do
#  if [ $i == "#{node[:puppet_master][:fqdn]}" ]; then
#    continue
#  fi

#{bin_dir}/puppet cert clean $i
