#
# Cookbook Name:: sampleApp
# Recipe:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

include_recipe 'build-essential'

# the app sits in a directory under files/default/counterService
# this is a terrible way to distribute software, but good enough for demo purposes
remote_directory node['sampleApp']['appPath'] do
  source 'counterService'
end

file "#{node['sampleApp']['appPath']}/config.yml" do
  content "redis_host: localhost"
end

# from the poise cookbook example
application node['sampleApp']['appPath'] do
  bundle_install do
    deployment true
  end
  unicorn do
    port 9000
  end
end
