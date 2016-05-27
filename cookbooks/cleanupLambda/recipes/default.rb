#
# Cookbook Name:: cleanupLambda
# Recipe:: default
#
# Copyright 2016 Fast Robot, LLC, Apache 2.0

# the user-data of the workstation setup setup an env var for the key id, but you could also pass it as an attribute
# $ aws kms describe-key --key-id $CHEF_KMS_KEYID

# I need the user key filename
Chef::Config.from_file("#{node['cleanupLambda']['chef_dir']}/knife.rb")

# clone a known working revision
git "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup" do
  repository node['cleanupLambda']['git_repo']
  revision node['cleanupLambda']['git_revision']
end


command_string = "aws kms encrypt --key-id #{node['cleanupLambda']['key_id']} " +
    "--plaintext file://#{Chef::Config[:client_key]} " +
    "--query CiphertextBlob | sed 's/\"//g' "

key_command =  Mixlib::ShellOut.new(command_string)
key_command.run_command

# the bundled lambda zipfile expects this key
# note that the encrypted key would change everytime it was generated, so I'm using create_if_missing
# that means if you changed the key you'll need to delete the encrypted_pem.txt
file "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup/lambda/encrypted_pem.txt" do
  content key_command.stdout
  action :create_if_missing
end

file "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup/lambda/local_config.py" do
  variables({
      :chef_server_url => Chef::Config[:chef_server_url],
      :region => ENV['AWS_DEFAULT_REGION'],
      :chef_username => Chef::Config[:node_name]
            })
  action :create
end

# Install terraform and use it to install the lambda

remote_file "#{Chef::Config[:file_cache_path]}/terraform.zip" do
  source "https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_linux_amd64.zip"
  notifies :run, "execute[unpack terraform]"
end

directory "#{Chef::Config[:file_cache_path]}/terraform"

execute "unpack terraform" do
  cwd "#{Chef::Config[:file_cache_path]}/terraform"
  command "unzip #{Chef::Config[:file_cache_path]}/terraform.zip"
  action :nothing
end

package "zip"

# create the zip file
execute "create lambda payload zip" do
  cwd "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup/lambda"
  command "zip -r ../lambda_function_payload.zip ."
  creates "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup/lambda_function_payload.zip"
  #notifies :execute, "execute[terraform apply]"
end

# terraform apply terraform
execute "terraform apply" do
  cwd "#{Chef::Config[:file_cache_path]}/lambda-chef-node-cleanup"
  command "#{Chef::Config[:file_cache_path]}/terraform/terraform apply terraform"
  #action :nothing
end

# grab the key policy and make sure the lambda is allowed to use the key
ruby

# aws kms get-key-policy --key-id #{node['cleanupLambda']['key_id']} --policy-name default --output text
# require 'json'
#

# aws kms put-key-policy --key-id #{node['cleanupLambda']['key_id']} --policy-name default --generate-cli-skeleton