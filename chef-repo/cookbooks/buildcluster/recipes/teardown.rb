#
# Cookbook Name:: buildcluster
# Recipe:: teardown
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

# This recipe tears down the world
require 'chef/provisioning/aws_driver'
# Pick your aws region
with_driver "aws::#{node['buildcluster']['aws_region']}"
# Point to your Chef credentials...there is probably a better way to do this...
with_chef_server node['buildcluster']['chef_server_url'],
  :client_name => node['buildcluster']['chef_client_name'],
  :signing_key_filename => node['buildcluster']['chef_signing_key_filename']

# Delete the machines
machine 'db1' do
  action :destroy
end

1.upto(node['buildcluster']['num_web_instances']) do |inst|
    machine "web#{inst}" do
      action :destroy
    end
end

load_balancer 'aws-chef-elb' do
  action :destroy
end

# Purge the VPC to remove subnets and security groups
aws_vpc 'aws-chef-vpc' do
  action :purge
end

# Now delete the empty VPC
aws_vpc 'aws-chef-vpc' do
  action :destroy
end
