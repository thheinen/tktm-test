#!/bin/bash -e

sudo cp tk_code/chef_target.rb /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/test-kitchen-*/lib/kitchen/provisioner/
sudo cp tk_code/train.rb ~/.chef/gem/ruby/3.1.0/gems/kitchen-transport-train-0.1.0/lib/kitchen/transport/

sudo cp -r tk_code/chef/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-1*/
sudo cp -r tk_code/chef-config/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-config-*/
sudo cp -r tk_code/mixlib/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/mixlib-shellout-*/
sudo cp -r tk_code/train/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/train-core-*/