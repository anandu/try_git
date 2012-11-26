#!/bin/bash
echo "Please enter branch name for the current project"
read project

cd /tmp  && git clone git@github.com:anandu/rightscale_cookbooks_private.git
cd /tmp/rightscale_cookbooks_private/cookbooks/rightscale/files/default/ && \
gem install right_cloud_api-0.0.0.gem --no-ri --no-rdoc && echo "Gem installed successfilly"

# Modifying .config.yaml with optimum setting
cp /root/virtualmonkey/.config.yaml{,.bak}
cp /root/virtualmonkey/config.yaml /root/virtualmonkey/.config.yaml

# Copying cloud crendential in .fog
cat <<EOF >> /root/.fog
:aws_access_key_id_test: "none"
:aws_secret_access_key_test: "none"
:rackspace_managed_auth_key: "none"
:rackspace_managed_username: "none"
EOF

# Modifying default values to match our environment
cd /root/virtualmonkey/collateral/servertemplate_tests/ && git checkout $project
sed -i -e 's/2901/47738/g' -e 's/306150001/323487001/g' -e 's/8888/8000/g' -e 's/publish-test/rs_templates/g' features/three_tier_shared_feature_lamp.rb
sed -i -e 's/2901/47738/g' -e 's/187123/268127001/g'  -e 's/356585001/284232001/g' mixins/lamp_chef.rb
git stash

echo "Please finish the colateral coding"
echo "To start testing , please issue command 'git stash apply'"
