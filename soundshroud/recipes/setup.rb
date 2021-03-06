# setup script here

include_recipe "ruby-ng::dev"
include_recipe "nodejs"
include_recipe "redisio"
include_recipe "redisio::enable"
include_recipe "postgres"
include_recipe "nginx"
include_recipe "unicorn"

apt_package 'zlib1g-dev'
apt_package 'libpq-dev'
apt_package 'libsox-fmt-all'
apt_package 'sox'
apt_package 'libchromaprint-dev'

template "soundshroud_service" do
    path "/etc/init.d/soundshroud"
    source "soundshroud_service.erb"
    owner "root"
    group "root"
    mode "0755"
end

service "soundshroud" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action [ :enable ]
end 

template "#{node['nginx']['dir']}/sites-available/soundshroud" do
  source 'soundshroud_site.erb'
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site 'soundshroud' do
  action :enable
end

directory '/tmp/sockets/' do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

unicorn_config "/opt/unicorn.rb" do
  listen ({"unix:/tmp/sockets/unicorn.sock": nil})
  working_directory node[:soundshroud][:path]
  # /config/unicorn.rb
end