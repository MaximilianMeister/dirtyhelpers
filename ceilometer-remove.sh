#!/usr/bin/bash

# run this on the admin node
cd /opt/dell

curl https://github.com/MaximilianMeister/barclamp-ceilometer/commit/8e2d740b7907ebce81191f7edfd755e775fda5b4.diff | patch -p1
knife role from file chef/roles/ceilometer-cagent_remove.rb
knife role from file chef/roles/ceilometer-agent_remove.rb
knife role from file chef/roles/ceilometer-server_remove.rb
knife cookbook upload -o /opt/dell/chef/cookbooks/ ceilometer

curl https://github.com/MaximilianMeister/barclamp-deployer/commit/d7446a8d60c8114e56206538f48c787515bfa2d7.diff | patch -p1
knife cookbook upload -o /opt/dell/chef/cookbooks/ barclamp

curl https://github.com/MaximilianMeister/barclamp-crowbar/commit/11c9c7acca26279dd7d2ed1d61c5470c7aec318d.diff | patch -p1
rccrowbar restart
