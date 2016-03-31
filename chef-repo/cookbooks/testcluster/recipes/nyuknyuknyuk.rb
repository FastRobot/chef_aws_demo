#
# Cookbook Name:: testcluster
# Recipe:: nyuknyuknyuk
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# This recipe tears down the world
require 'chef/provisioning/aws_driver'
# Pick your aws region
with_driver 'aws::us-west-1'
# Point to your Chef credentials...there is probably a better way to do this...
with_chef_server "https://api.chef.io/organizations/jcook-chef-learning",
  :client_name => 'jcook-fastrobot',
  :signing_key_filename => '/Users/jcook/fastrobot/AWS/.chef/jcook-fastrobot.pem'

# Delete the machines
machine_batch do
  action :destroy
  machines ['curly', 'larry', 'moe']
end

# Purge the VPC to remove subnets and security groups
aws_vpc 'aws-chef-vpc' do
  action :purge
end

# Now delete the empty VPC
aws_vpc 'aws-chef-vpc' do
  action :destroy
end
