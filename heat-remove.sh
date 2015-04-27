#!/usr/bin/bash

# run this on the admin node
cd /opt/dell

curl https://github.com/MaximilianMeister/barclamp-heat/commit/602c38675f13db4a17d88dc16d6c6e184deb66b6.diff | patch -p1
knife role from file chef/roles/heat-server_remove.rb
knife cookbook upload -o /opt/dell/chef/cookbooks/ heat

curl https://github.com/MaximilianMeister/barclamp-deployer/commit/d7446a8d60c8114e56206538f48c787515bfa2d7.diff | patch -p1
knife cookbook upload -o /opt/dell/chef/cookbooks/ barclamp

curl https://patch-diff.githubusercontent.com/raw/crowbar/barclamp-crowbar/pull/1224.diff | patch -p1
rccrowbar restart
