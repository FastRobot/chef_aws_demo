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

# need to modify the file lambda/main.py
# REGION= 'us-west-2' # Change to region your AWS Lambda function is in
# CHEF_SERVER_URL = 'https://your.domain/organizations/your_organization'
# USERNAME = 'CHEF_USER'

# after that, while terrible, I could install terraform and use it to install the lambda