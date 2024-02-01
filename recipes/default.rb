apt_repository 'deadsnakes' do
  uri 'ppa:deadsnakes/ppa'

  notifies :update, 'apt_update[deadsnakes]', :immediately
end

apt_update 'deadsnakes' do
  action :nothing
end

apt_preference 'deadsnakes' do
  pin          'version 3.12'
  pin_priority '700'
end

apt_package 'python3.12'

alternatives 'python install 3.12' do
  link_name 'python3'
  path '/usr/bin/python3.12'
  priority 100
  action :install
end

# execute 'fix_apt' do
#   command 'ln -s /usr/lib/python3/apt_pkg.cpython-3*-x86_64-linux-gnu.so apt_pkg.so'
#   creates '/usr/lib/python3/dist-packages/apt_pkg.so'
#   cwd '/usr/lib/python3/dist-packages'
# end

chef_client_config 'Create client.rb' do
  chef_server_url 'https://chef.example.dmz'
  log_level :info
  log_location :syslog
  http_proxy 'proxy.example.dmz'
  https_proxy 'proxy.example.dmz'
  no_proxy %w(internal.example.dmz)
end

cron_access 'nobody' do
  action :deny
end

cron_d 'noop' do
  hour '5'
  minute '0'
  command '/bin/true'
end

hostname 'rename' do
  hostname 'chef-target'
end

kernel_module 'loop' do
  options [
    'max_loop=4',
    'max_part=8',
  ]
end

locale 'set system locale' do
  lang 'en_US.UTF-8'
end

ohai_hint 'example' do
  hint_name 'ec2'
end

directory '/etc/selinux/local'

=begin
selinux_install 'example'

selinux_module 'myapp' do
  source 'myapp.te'
  action :create
end

selinux_boolean 'ssh_sysadm_login' do
  value 'on'
end

selinux_fcontext '/var/www/moodle(/.*)?' do
  secontext 'httpd_sys_rw_content_t'
end

selinux_login 'test' do
  user 'test_u'
  range 's0'
end

selinux_permissive 'httpd_t'

selinux_state 'permissive' do
  action :permissive
end

selinux_port '5678' do
  protocol 'tcp'
  secontext 'http_port_t'
end

selinux_user 'chef' do
  level 's0'
  range 's0'
  roles %w(sysadm_r staff_r)
end
=end

ssh_known_hosts_entry 'github.com'

sudo 'admin' do
  user 'chef'
end

sysctl 'vm.swappiness' do
  value 19
end

systemd_unit 'sysstat-collect.timer' do
  content <<~EOU
  [Unit]
  Description=Run system activity accounting tool every 10 minutes

  [Timer]
  OnCalendar=*:00/10

  [Install]
  WantedBy=sysstat.service
  EOU

  action [:create, :enable]
end

timezone 'UTC'

user_ulimit 'chef' do
  filehandle_limit 8192
end

subversion 'CouchDB Edge' do
  repository 'http://svn.apache.org/repos/asf/couchdb/trunk'
  revision 'HEAD'
  destination '/opt/my_sources/couch'
  action :sync
end

file '/tmp/basefile' do
  content 'This is a placeholder file'
  mode '0754'
  owner 'nobody'
  group 'nogroup'
end

template '/tmp/example' do
  source 'example.erb'
  variables({
    example: 'farce'
  })
  mode '0654'
end

cookbook_file '/tmp/file.txt' do
  source 'cookbook_file.txt'
  mode '0543'
  owner 'nobody'
  group 'nogroup'
end

directory '/tmp/testdir'

remote_file '/tmp/testdir/index.hml' do
  source 'https://docs.chef.io/resources/remote_file/index.html'
end

remote_directory '/tmp/testdir/1/2/3' do
  source 'directory'
end

link '/tmp/index.hmtl' do
  to '/tmp/testdir/index.hml'
end

directory '/home/ubuntu/app_name' do
  action :delete
end

# .. kinda works .. on the second run.
# TODO: Unexpected exit status of 128 running ["git checkout 3cad29b8ba4f5568fa84d6e50d7712f08b1f2345"]
#git "/home/ubuntu/app_name" do
#  repository "https://github.com/thheinen/goof"
#  action :checkout
#end

user 'chef' do
  comment 'Chef'
  shell '/bin/bash'
  password 'c8ef27dfa69443a3a4f07384de7e7fc2f2e09c7e5cf3e818adfbb9a86c794146' # C0deCan!
  action :create
end

group 'chefs' do
  members 'chef'
  append true
end
