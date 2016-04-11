#
# Cookbook Name:: sampleApp
# Recipe:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

# install the redis-server package
package 'redis-server'

# write out a simple redis config
cookbook_file '/etc/redis/redis.conf' do
  notifies :restart, 'service[redis-server]'
end

# start the service
service 'redis-server' do
  action [:enable, :start]
end