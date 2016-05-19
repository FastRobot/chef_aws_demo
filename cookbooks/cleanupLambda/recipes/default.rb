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

# pam_config = "/etc/pam.d/su"
# commented_limits = /^#\s+(session\s+\w+\s+pam_limits\.so)\b/m
#
# ruby_block "add pam_limits to su" do
#   block do
#     sed = Chef::Util::FileEdit.new(pam_config)
#     sed.search_file_replace(commented_limits, '\1')
#     sed.write_file
#   end
#   only_if { ::File.readlines(pam_config).grep(commented_limits).any? }
# end if platform_family?('debian')

# after that, while terrible, I could install terraform and use it to install the lambda

remote_file "#{Chef::Config[:file_cache_path]}/terraform.zip" do
  source "https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_linux_amd64.zip"
  notifies :run, "execute[unpack terraform]"
end

directory "/opt/terraform"

execute "unpack terraform" do
  cwd "/opt/terraform"
  command "unzip #{Chef::Config[:file_cache_path]}/terraform.zip"
  action :nothing
end

package "zip"

# create the zip file
# zip -r lambda_function_payload.zip lambda

# apply the zipfile
# terraform apply terraform