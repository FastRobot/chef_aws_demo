#
# Cookbook Name:: buildcluster
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chef/provisioning/aws_driver'
with_driver "aws::#{node['buildcluster']['aws_region']}"

with_chef_server node['buildcluster']['chef_server_url'],
  :client_name => node['buildcluster']['chef_client_name'],
  :signing_key_filename => node['buildcluster']['chef_signing_key_filename']

aws_vpc 'aws-chef-vpc' do
  cidr_block '10.0.0.0/23'
  internet_gateway true
  main_routes '0.0.0.0/0' => :internet_gateway
  enable_dns_hostnames true
end

aws_subnet 'aws-chef-web-subnet' do
  vpc 'aws-chef-vpc'
  cidr_block '10.0.0.0/24'
  map_public_ip_on_launch true
end

aws_subnet 'aws-chef-db-subnet' do
  vpc 'aws-chef-vpc'
  cidr_block '10.0.1.0/24'
  map_public_ip_on_launch true
end

aws_security_group 'aws-chef-web-sg' do
  vpc 'aws-chef-vpc'
  inbound_rules '0.0.0.0/0' => [ 22, 9000 ]
end

aws_security_group 'aws-chef-db-sg' do
  vpc 'aws-chef-vpc'
  inbound_rules '0.0.0.0/0' => [ 22 ],
                '10.0.0.0/24' => [ 6379 ]
end

#
## Build the database box first
machine 'db1' do
  machine_options bootstrap_options: {
    image_id: 'ami-df6a8b9b',
    instance_type: 't2.micro',
    subnet: 'aws-chef-db-subnet',
    security_group_ids: ['aws-chef-db-sg']
    },
    convergence_options: {
      ssl_verify_mode: :verify_none
    }
  recipe 'apt'
  recipe 'sampleApp::db'
end

with_machine_options({
  bootstrap_options: {
    image_id: 'ami-06116566',
    instance_type: 't2.micro',
    subnet: 'aws-chef-web-subnet',
    security_group_ids: ['aws-chef-web-sg']
  },
  convergence_options: {
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

load_balancer "aws-chef-elb" do
  machines (1..node['buildcluster']['num_web_instances']).map { |inst| "web#{inst}" }
  load_balancer_options({
    :listeners => [{
      :port => 80,
      :protocol => :http,
      :instance_port => 9000,
      :instance_protocol => :http,
    }],
    health_check: {
      healthy_threshold:    2,
      unhealthy_threshold:  4,
      interval:             12,
      timeout:              5,
      target:               'HTTP:9000/'
    },
    subnets: 'aws-chef-web-subnet',
    security_groups: 'aws-chef-web-sg'
  })
end
