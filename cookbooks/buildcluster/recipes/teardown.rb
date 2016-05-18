#
# Cookbook Name:: buildcluster
# Recipe:: teardown
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

# This recipe tears down the world
require 'chef/provisioning/aws_driver'
# Pick your aws region
with_driver "aws::#{node['buildcluster']['aws_region']}"

Chef::Config.from_file("#{node['buildcluster']['chef_dir']}/knife.rb")

with_chef_server Chef::Config[:chef_server_url],
  :client_name => Chef::Config[:node_name],
  :signing_key_filename => Chef::Config[:client_key]

# Delete the machines
machine 'db1' do
  action :destroy
end

1.upto(node['buildcluster']['num_web_instances']) do |inst|
    machine "web#{inst}" do
      action :destroy
    end
end

load_balancer 'chef-aws-elb' do
  action :destroy
end

# Purge the VPC to remove subnets and security groups
aws_vpc 'chef-aws-vpc' do
  action :purge
end

# Delete the Security Groups
['chef-aws-db-sg','chef-aws-web-sg'].each do |sg|
  aws_security_group sg do
    action :delete
  end
end

# Delete the Subnets
['chef-aws-db-subnet','chef-aws-web-subnet'].each do |sn|
  aws_subnet sn do
    action :delete
  end
end

# Now delete the empty VPC
aws_vpc 'chef-aws-vpc' do
  action :destroy
end
