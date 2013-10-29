#!/bin/bash
export EDITOR=vim
# knife configure -i --defaults
git clone git://github.com/chetanshirke/chef_test.git /var/chef/cookbooks
knife cookbook upload -o /var/chef/cookbooks:/var/chef/cookbooks/cookbooks -a
for i in "ntp" "bagtest"; do
  knife role create $i
done
knife data bag create password id
knife environment create production
