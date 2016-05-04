#
# Cookbook Name:: buildcluster
# Recipe:: teardown
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

# This recipe tears down the world
require 'chef/provisioning/aws_driver'
# Pick your aws region
with_driver "aws::#{node['buildcluster']['aws_region']}"

creds = getKnifeCreds 'Reading Knife Creds' do
  chef_dir node['buildcluster']['chef_dir']
end

with_chef_server creds['chef_server_url'],
  :client_name => creds['node_name'],
  :signing_key_filename => creds['client_key']

# Batch delete the machines
machine_batch 'Terminate all of the machines!!!' do
  machine 'db1' do
    action :destroy
  end

  1.upto(node['buildcluster']['num_web_instances']) do |inst|
      machine "web#{inst}" do
        action :destroy
      end
  end
end

# Delete the ELB now that machines are gone
load_balancer 'chef-aws-elb' do
  action :destroy
end

# Delete the subnets
aws_subnet 'chef-aws-web-subnet' do
  action :delete
end

aws_subnet 'chef-aws-db-subnet' do
  action :delete
end

# Delete the Security groups
aws_security_group 'chef-aws-web-sg' do
  action :delete
end

aws_security_group 'chef-aws-db-sg' do
  action :delete
end

# Purge the VPC to remove anything we missed
aws_vpc 'chef-aws-vpc' do
  action :purge
end

# Now delete the empty VPC
aws_vpc 'chef-aws-vpc' do
  action :destroy
end
