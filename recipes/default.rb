=begin
apt_repository 'deadsnakes' do
  uri 'ppa:deadsnakes/ppa'
  key 'F23C5A6CF475977595C89F51BA6932366A755776'
  notifies :update, 'apt_update[deadsnakes]', :immediately
end

execute 'fix_apt' do
  command 'ln -s /usr/lib/python3/dist-packages/apt_pkg.cpython-3*-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/apt_pkg.so'

  not_if 'test -e /usr/lib/python3/dist-packages/apt_pkg.so'
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

# "file: ArgumentError: wrong number of arguments (given 1, expected 0)" without stacktrace
# locale 'set system locale' do
#   lang 'en_US.UTF-8'
# end

ohai_hint 'example' do
  hint_name 'ec2'
end

directory '/etc/selinux/local'


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

ssh_known_hosts_entry 'github.com'

# Verification fails: Probably local tempfile + remote verification = "file not found"
# sudo 'admin' do
#   user 'chef'
# end

sysctl 'vm.swappiness' do
  value 19
end

# Verification fails: Probably local tempfile + remote verification = "file not found"
# systemd_unit 'sysstat-collect.timer' do
#   content <<~EOU
#   [Unit]
#   Description=Run system activity accounting tool every 10 minutes
#
#   [Timer]
#   OnCalendar=*:00/10
#
#   [Install]
#   WantedBy=sysstat.service
#   EOU
#
#   action [:create, :enable]
# end

timezone 'UTC'

user_ulimit 'chef' do
  filehandle_limit 8192
end

directory '/opt/my_sources'

# apt_package 'subversion'

# subversion 'CouchDB Edge' do
#   repository 'http://svn.apache.org/repos/asf/couchdb/trunk'
#   revision 'HEAD'
#   destination '/opt/my_sources/couch'
#   action :sync
# end

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

=begin
rhsm_errata 'RHSA:2018-1234'

rhsm_errata_level 'example_install_moderate' do
  errata_level 'moderate'
end

rhsm_repo 'rhel-7-server-extras-rpms' do
  action :disable
end

swap_file '/tmp/swap' do
  size 1024
end

service 'ssh' do
  action [:enable, :start]
end

apt_update

apt_package 'net-tools'

# "directory: ArgumentError: wrong number of arguments (given 1, expected 0)" without stacktrace
# ifconfig 'Create LO alias' do
#   target '100.64.0.1'
#   device 'lo:0'
#   mask '255.240.0.0'
# end

# route '100.64.0.0/12' do
#   device 'lo:0'
# end

http_request 'WhatIsMyIP' do
  url 'https://checkip.amazonaws.com'
end

execute 'mkfs' do
  command 'mkfs.ext3 /tmp/flatfile'

  action :nothing
  only_if 'test -e /tmp/flatfile' # Document: Ruby Guards will need TargetIO(?)
end

execute 'flatfile' do
  command 'dd if=/dev/zero of=/tmp/flatfile bs=1k count=1024'
  creates '/tmp/flatfile'

  not_if 'test -e /tmp/flatfile'
  notifies :run, 'execute[mkfs]', :immediately
end

mount '/mnt' do
  device '/tmp/flatfile'
  enabled true

  only_if 'mount --fake /tmp/flatfile /mnt' # should be in desired state?
end

file '/mnt/loopy' do
  content <<~TEXT
    Hello world
  TEXT
end

snap_package 'hello-world' do
  action :install
end

=begin
snap_package 'hello-world' do
  action :install
end

snap_package 'hello-world' do
  action :remove
end


habitat_install

habitat_sup 'default' do
  license 'accept'
end

habitat_package 'core/nginx'
habitat_service 'core/nginx'
# Chef::Exceptions::ValidationFailed: Proposed content for /etc/systemd/system/hab-sup.service failed verification :systemd_unit (Chef::Resource::File::Verification::SystemdUnit)

habitat_config 'nginx.default' do
  config({
    worker_count: 2,
    http: {
      keepalive_timeout: 120
    }
  })
end

habitat_service 'core/nginx unload' do
  service_name 'core/nginx'
  action :unload
end



cron 'name_of_cron_entry' do
  minute '0'
  hour '8'
  weekday '6'
  mailto 'admin@example.com'
  command 'echo'
  action :create
end

cron 'name_of_cron_entry' do
  user 'hab'
  minute '0'
  hour '20'
  day '*'
  month '11'
  weekday '1-5'
  command 'echo'
  action :create
end
=end

#ohai_hint 'example' do
#  hint_name 'custom'
#end

#bash 'foo' do
#  code 'touch /tmp/this'
#end

=begin
chef_data_bag 'data_bag' do
  action :create
end

chef_data_bag_item 'data_bag/id' do
  raw_data({
    "feature" => true
  })
end

chef_environment 'dev' do
  description 'Dev Environment'
  default_attributes({ "dev" => 1 })
end

#apt_update do
#  action :update
#end
#apt_package 'apt-transport-https'
#apt_package 'cowsay'

# Should auto-select snap_tm because snap_package doesn't support target_mode
#snap_package 'hello-world' do
#  action :install
#end#

#snap_package 'hello-world' do
#  action :remove
#end
#bash 'Wroomwroom' do
#  name 'Wroomwroom'
#  code <<~EOF
#    cowsay 'wroom' > /tmp/testfile
#    date >> /tmp/testfile
#    cowsay 'wroom' >> /tmp/testfile
#  EOF
#end

#subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
#yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

package "cowsay" do
  #version "3.7.0"
end

package "cowsay" do
  action :remove
end

selinux_install 'example' do
  packages %w(policycoreutils selinux-policy selinux-policy-targeted)
  action :install
end

timezone "Set the host's timezone to America/Los_Angeles" do
  timezone 'America/Los_Angeles'
end
=end

# Chef::Exceptions::InsufficientPermissions
#apt_update 'update' do
#  action :update
#end
#package 'nginx' do # apt_package
#  action :install
#end
=begin
  * apt_update[update] action update[2024-09-13T12:21:09+00:00] INFO: Processing apt_update[update] action update (tktm_test::default line 416)

    * directory[/var/lib/apt/periodic] action create[2024-09-13T12:21:09+00:00] INFO: Processing directory[/var/lib/apt/periodic] action create (tktm_test::default line 72)
 (up to date)
    * directory[/etc/apt/apt.conf.d] action create[2024-09-13T12:21:09+00:00] INFO: Processing directory[/etc/apt/apt.conf.d] action create (tktm_test::default line 72)
 (up to date)
    * file[/etc/apt/apt.conf.d/15update-stamp] action create_if_missing[2024-09-13T12:21:10+00:00] INFO: Processing file[/etc/apt/apt.conf.d/15update-stamp] action create_if_missing (tktm_test::default line 77)
 (up to date)
    * execute[apt-get -q update] action run[2024-09-13T12:21:11+00:00] INFO: Processing execute[apt-get -q update] action run (tktm_test::default line 82)
[2024-09-13T12:21:32+00:00] INFO: execute[apt-get -q update] ran successfully

      - execute ["apt-get", "-q", "update"]
    - force update new lists of packages
  * apt_package[nginx] action install[2024-09-13T12:21:32+00:00] INFO: Processing apt_package[nginx] action install (tktm_test::default line 419)
[2024-09-13T12:21:43+00:00] INFO: apt_package[nginx] installed nginx at 1.18.0-0ubuntu1.5

    - install version 1.18.0-0ubuntu1.5 of package nginx
=end

# A40
# error: Chef::Exceptions::CookbookNotFound: Cookbook @recipe_files not found.
#template '/etc/ssh/ssh_known_hosts' do
#  source 'ssh_known_hosts.erb' # This refers to the ERB file in templates/default
#  owner 'root'
#  group 'root'
#  mode '0644'
#  action :create
#end
=begin
  * template[/etc/ssh/ssh_known_hosts] action create[2024-09-13T12:21:45+00:00] INFO: Processing template[/etc/ssh/ssh_known_hosts] action create (tktm_test::default line 431)
[2024-09-13T12:21:45+00:00] INFO: template[/etc/ssh/ssh_known_hosts] created file /etc/ssh/ssh_known_hosts

    - create new file /etc/ssh/ssh_known_hosts[2024-09-13T12:21:47+00:00] INFO: template[/etc/ssh/ssh_known_hosts] updated file contents /etc/ssh/ssh_known_hosts

    - update content in file /etc/ssh/ssh_known_hosts from none to e3b0c4
    (no diff)[2024-09-13T12:21:47+00:00] INFO: template[/etc/ssh/ssh_known_hosts] owner changed to 0
[2024-09-13T12:21:47+00:00] INFO: template[/etc/ssh/ssh_known_hosts] group changed to 0
[2024-09-13T12:21:47+00:00] INFO: template[/etc/ssh/ssh_known_hosts] mode changed to 644

    - change mode from '' to '0644'
    - change owner from '' to 'root'
    - change group from '' to 'root'
=end


# error: Mixlib::ShellOut::ShellCommandFailed: Unexpected exit status of 2 running ["useradd", "-c", "Deploy User", "-s", "/bin/bash", "-d", "/home/deploy", "-m", "deploy"]
#user 'deploy' do
#  comment 'Deploy User' # if this has a space, it'll explode -> general bug!
#  home '/home/deploy'
#  shell '/bin/bash'
#  manage_home true
#  action :create
#end
# Confirmed.
# Unexpected exit status of 2 running ["useradd", "-c", "Deploy User", "-s", "/bin/bash", "-d", "/home/deploy", "-m", "deploy"]: Usage: useradd [options] LOGIN
#  useradd -D
#  useradd -D [options]

# A44
#systemd_unit 'my_custom_service.service' do
#  content(
#    {
#      'Unit' => {
#        'Description' => 'My Custom Service',
#        'After' => 'network.target',
#      },
#      'Service' => {
#        'ExecStart' => '/usr/bin/my_custom_script.sh',
#        'Restart' => 'on-failure',
#      },
#      'Install' => {
#        'WantedBy' => 'multi-user.target',
#      },
#    }
#  )
#  action [:create, :enable, :start]
#end

# NA2
# chef_data_bag 'data_bag' do
#   action :create
# end
# chef_data_bag_item 'data_bag/id' do
#   raw_data({
#     "feature" => true
#   })
# end

# NA6 -> this works. just slow
#user 'hab' do
#  gid 'hab'
#  action :modify
#end
#habitat_install
#habitat_package 'vim' do
#  action :install
#  version '8.2.2825'
#  channel 'stable'
#end

# NA7
# apt_update 'now' do
#   action :update
# end
# package 'ksh'
# ksh 'hello world' do # just wasn't installed
#   code <<-EOH
#     echo "Hello world!"
#     echo "Current directory: " $cwd
#   EOH
# end

# NA9
# Define an InSpec input variable for use in compliance profiles
#inspec_input 'openssh' do
#  action :add
#end
=begin
RuntimeError: inspec_input[openssh] (tktm_test::default line 531) had an error: RuntimeError: include_input was given a nil value
=end

# NA12
# package 'csh'
# csh 'run_example_script' do # just needed the package
#   code <<-EOH
#     echo Yo
#   EOH
#   action :run
# end

=begin
# fixed
package 'git'
git '/tmp/chef-repo' do
  repository 'https://github.com/chef/chef.git'
  revision 'main'
  action :sync
end

# no issue
directory '/tmp/cookbooks'
cookbook_file '/tmp/cookbooks/config.conf' do
  source 'config.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# no issue
template '/etc/ssh/ssh_known_hosts' do
  source 'ssh_known_hosts.erb' # This refers to the ERB file in templates/default
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# fixed
sudo 'webadmin_apache' do
  user 'root'
  commands ['/bin/systemctl restart httpd']
  nopasswd true
  action :create
end

# no issue... if you name it "crond" on redhat
service 'crond' do
  action %i(enable start)
end

cron 'daily_script' do
  minute '0'
  hour '0'
  command '/tmp/local/bin/daily_script.sh'
  user 'ec2-user' # "ubuntu" or "ec2-user"
  action :create
end

# no issues
package 'httpd' do
  action :install
end

selinux_install 'selinux' do
  action :install
end

rhsm_register 'register_with_rhsm' do
  username 'chnadraredhat'
  password 'Dev@progress123'
  auto_attach true
  action :register
end

rhsm_subscription 'attach_subscription' do
  pool_id '2c94582e918fd1090191db3a9e083436'
  action :attach
end
=end


perl 'hello world' do
  code <<-EOH
    print "Hello world! From Chef and Perl.";
  EOH
end
# Mixlib::ShellOut::ShellCommandFailed: perl[hello world] (tktm_test::default line 554) had an error: Mixlib::ShellOut::ShellCommandFailed: Unexpected exit status of 255 running ["\"perl\" "]: Bareword found where operator expected at - line 1, near """Hello"

python 'hello world' do
  code <<~EOH
    print("Hello world! From Chef and Python.")
  EOH
  interpreter 'python3'
end
