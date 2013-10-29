#!/bin/bash
cd /home/anand/code/rightscale_cookbooks/cookbooks

# Finds files changed since last commit.
abc=`git diff --cached --name-only HEAD | cut -d/ -f2-`

# Checking syntax error, scipt will exit with error with syntanx error found at first file.
for i in $abc;do
  # test $(ruby -c $i) | echo "error"
  ruby -c $i || exit 1
done
# Checks if metadata json is generated is metadata.rb has been modified.
echo "$abc" | grep -q metadata.rb && echo "$abc" | grep -q metadata.json \
|| echo "no metadata json generated" && exit 1
