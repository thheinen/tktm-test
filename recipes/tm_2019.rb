# Only Test Resources from Original Target Mode in 2019 (>= 15.1.36)

# execute 'apt-get update'

# apt_package 'apache2' do
#   return [0, 1]
# end

# service 'apache2' do
#   action [:enable, :start]
# end

# execute 'add-apt-repository ppa:deadsnakes/ppa --yes'
# execute 'apt-get clean'
# execute 'apt-get update'
# execute 'apt-get install python3.12 --yes'

# alternatives 'python install 3.12' do
#   link_name '/usr/bin/python3'
#   path '/usr/bin/python3.12'
#   priority 100
#   action :install
# end

file '/tmp/basefile' do
  content 'This is a placeholder file'
  mode '0754'
  owner 'nobody'
  group 'nogroup'
end

#template '/tmp/example' do
#  source 'example.erb'
#  variables({
#    test: 'farce'
#  })
#  mode '0654'
#end

# apt_preference 'deadsnakes' do
#   pin          'version 3.12'
#   pin_priority '700'
# end

