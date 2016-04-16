#
# Cookbook Name:: testcluster
# Recipe:: stooges.rb
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

require 'chef/provisioning/aws_driver'
with_driver 'aws::us-west-1'

with_chef_server "https://api.chef.io/organizations/jcook-chef-learning",
  :client_name => 'jcook-fastrobot',
  :signing_key_filename => '/Users/jcook/fastrobot/AWS/.chef/jcook-fastrobot.pem'

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

aws_security_group 'aws-chef-sg' do
  vpc 'aws-chef-vpc'
  inbound_rules '0.0.0.0/0' => [ 22, 80 ]
end

machine 'larry' do
  machine_options bootstrap_options: {
    image_id: 'ami-06116566',
    instance_type: 't2.micro'
    },
    convergence_options: {
      ssl_verify_mode: :verify_none
    }
end

machine 'moe' do
  machine_options bootstrap_options: {
    image_id: 'ami-06116566',
    instance_type: 't2.micro',
    subnet: 'aws-chef-web-subnet',
    security_group_ids: ['aws-chef-sg']
    },
    convergence_options: {
      ssl_verify_mode: :verify_none
    }
end

machine 'curly' do
  machine_options bootstrap_options: {
    image_id: 'ami-df6a8b9b',
    instance_type: 't2.micro',
    subnet: 'aws-chef-db-subnet',
    security_group_ids: ['aws-chef-sg']
    },
    convergence_options: {
      ssl_verify_mode: :verify_none
    }
end
