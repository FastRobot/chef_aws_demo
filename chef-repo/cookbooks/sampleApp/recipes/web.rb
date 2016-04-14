#
# Cookbook Name:: sampleApp
# Recipe:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

include_recipe 'build-essential'
include_recipe 'nginx'

template '/etc/nginx/nginx.conf' do
  notifies :restart, 'service[nginx]' 
end

backends = search('node','recipes:sampleApp\:\:db')
redis_host = backends.size > 0 ? backends.first.ipaddress : 'localhost'

# from the poise cookbook application_ruby
application node['sampleApp']['appPath'] do
  # the app sits in a directory under files/default/counterService
  # this is a terrible way to distribute software, just doing it for demo purposes
  # but you could replace this with a git resource easily
  remote_directory node['sampleApp']['appPath'] do
    source 'counterService'
  end
  file "#{node['sampleApp']['appPath']}/config.yml" do
    content "redis_host: #{redis_host}\n"
  end
  bundle_install do
    deployment true
  end
  unicorn do
    port 9000
  end
end
