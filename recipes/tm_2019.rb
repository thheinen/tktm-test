# Only Test Resources from Original Target Mode in 2019 (>= 15.1.36)

execute 'apt-get update'

apt_package 'apache2'

service 'apache2' do
  action [:enable, :start]
end
