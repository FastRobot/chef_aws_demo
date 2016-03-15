#
# Cookbook Name:: sampleApp-deploy
# Recipe:: instance
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# performs some per-instance tagging/manipulation to leverage AWS specific features

# NB: This is to be added to the run_list of each instance running our app.

# pretty sure with IAM roles I don't need this in each resource:
#   aws_access_key aws['aws_access_key_id']
#   aws_secret_access_key aws['aws_secret_access_key']

# register this node with the correct ELB. ELB was made in the default.rb

aws_elastic_lb "elb_sampleApp_#{node.chef_environment}" do
  name 'QA'
  action :register
end

# tag this resource with the name of the app as well as whatever environmental abstraction we happen to be in
aws_resource_tag node['ec2']['instance_id'] do
  tags('Name' => 'sampleApp server',
       'Environment' => node.chef_environment)
  action :update
end