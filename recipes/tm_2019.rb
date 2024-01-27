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

# Works
file '/tmp/basefile' do
  content 'This is a placeholder file'
  mode '0754'
  owner 'nobody'
  group 'nogroup'
end

# Works
template '/tmp/example' do
  source 'example.erb'
  variables({
    example: 'farce'
  })
  mode '0654'
end

# Works, including platform specific selection
cookbook_file '/tmp/file.txt' do
  source 'cookbook_file.txt'
  mode '0543'
  owner 'nobody'
  group 'nogroup'
end

# works
directory '/tmp/testdir'

# works. Pulls file from worker, not from target node though
remote_file '/tmp/testdir/index.hml' do
  source 'https://docs.chef.io/resources/remote_file/index.html'
end

# works
remote_directory '/tmp/testdir/1/2/3' do
  source 'directory'
end

# works
link '/tmp/index.hmtl' do
  to '/tmp/testdir/index.hml'
end

directory '/home/ubuntu/app_name' do
  action :delete
end

# mostly works
# TODO: Unexpected exit status of 128 running ["git checkout 3cad29b8ba4f5568fa84d6e50d7712f08b1f2345"]
git "/home/ubuntu/app_name" do
  repository "https://github.com/thheinen/goof"
  action :checkout
end

# TODO
user 'chef' do
  comment 'Chef'
  shell '/bin/bash'
  action :create
end

group 'chefs' do
  members 'chef'
  append true
end

# apt_preference 'deadsnakes' do
#   pin          'version 3.12'
#   pin_priority '700'
# end

