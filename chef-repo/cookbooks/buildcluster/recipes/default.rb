#
# Cookbook Name:: buildcluster
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chef/provisioning/aws_driver'
# Define your aws_region in the attributes file
with_driver "aws::#{node['buildcluster']['aws_region']}"

#
## Get the knife credentials to use for chef-provisioning
## and set our target chef_environment
creds = getKnifeCreds 'Reading Knife Creds' do
  chef_dir node['buildcluster']['chef_dir']
end

with_chef_server creds['chef_server_url'],
  :client_name => creds['node_name'],
  :signing_key_filename => creds['client_key']

with_chef_environment node['buildcluster']['chef_environment']

aws_vpc 'chef-aws-vpc' do
  cidr_block '10.0.0.0/23'
  internet_gateway true
  main_routes '0.0.0.0/0' => :internet_gateway
  enable_dns_hostnames true
end

aws_subnet 'chef-aws-web-subnet' do
  vpc 'chef-aws-vpc'
  cidr_block '10.0.0.0/24'
  map_public_ip_on_launch true
end

aws_subnet 'chef-aws-db-subnet' do
  vpc 'chef-aws-vpc'
  cidr_block '10.0.1.0/24'
  map_public_ip_on_launch true
end

aws_security_group 'chef-aws-web-sg' do
  vpc 'chef-aws-vpc'
  inbound_rules '0.0.0.0/0' => [ 22, 80 ]
end

aws_security_group 'chef-aws-db-sg' do
  vpc 'chef-aws-vpc'
  inbound_rules '0.0.0.0/0' => [ 22 ],
                '10.0.0.0/24' => [ 6379 ]
end

#
## Build the database box first
machine 'db1' do
  machine_options bootstrap_options: {
    image_id: node['buildcluster']['image_id'],
    instance_type: node['buildcluster']['instance_type'],
    subnet: 'chef-aws-db-subnet',
    security_group_ids: ['chef-aws-db-sg']
    },
    convergence_options: {
      chef_version: node['buildcluster']['chef_client_version'],
      ssl_verify_mode: :verify_none
    }
  recipe 'apt'
  recipe 'sampleApp::db'
end

with_machine_options({
  bootstrap_options: {
    image_id: node['buildcluster']['image_id'],
    instance_type: node['buildcluster']['instance_type'],
    subnet: 'chef-aws-web-subnet',
    security_group_ids: ['chef-aws-web-sg']
  },
  convergence_options: {
    chef_version: node['buildcluster']['chef_client_version'],
    ssl_verify_mode: :verify_none
  }
})

#
## Build the front-end webservers
1.upto(node['buildcluster']['num_web_instances']) do |inst|
    machine "web#{inst}" do
      recipe 'apt'
      recipe 'sampleApp::web'
    end
end

#
## Add the newly minted webservers into our load_balancer
load_balancer "chef-aws-elb" do
  machines (1..node['buildcluster']['num_web_instances']).map { |inst| "web#{inst}" }
  load_balancer_options({
    :listeners => [{
      :port => 80,
      :protocol => :http,
      :instance_port => 80,
      :instance_protocol => :http,
    }],
    health_check: {
      healthy_threshold:    2,
      unhealthy_threshold:  4,
      interval:             12,
      timeout:              5,
      target:               'HTTP:80/'
    },
    subnets: 'chef-aws-web-subnet',
    security_groups: 'chef-aws-web-sg'
  })
end
