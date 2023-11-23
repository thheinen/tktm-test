# Only Test Resources which use io

alternatives 'python install 3.9' do
  link_name 'python'
  path '/usr/bin/python3.9'
  priority 100
  action :install
end
