#!/bin/bash 

sudo cp -r tk_code/chef/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-1*/
sudo cp -r tk_code/chef-config/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-config-*/
sudo cp -r tk_code/kitchen-transport-train/* ~/.chef/gem/ruby/3.1.0/gems/kitchen-transport-train-0.*/
sudo cp -r tk_code/mixlib/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/mixlib-shellout-*/
sudo cp -r tk_code/ohai/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/ohai-*/
sudo cp -r tk_code/test-kitchen/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/test-kitchen-*/
sudo cp -r tk_code/train/* /opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/train-core-*/
echo
