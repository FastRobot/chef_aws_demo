#
## Edit this block on the top if you want a different AWS Region, or
## have manually installed the .chef directory outside /home/ubuntu/chef-repo/.chef
# the AWS location (default is us-west-1)
default['buildcluster']['aws_region'] = 'us-west-1'
# PATH to your .chef directory from the chef-starter.zip
default['buildcluster']['chef_dir'] = '/home/ubuntu/chef-repo/.chef'
# The chef_environment to deploy our nodes into in
default['buildcluster']['chef_environment'] = 'chef_aws_demo'

#
## machine details
default['buildcluster']['image_id'] = 'ami-df6a8b9b'
default['buildcluster']['instance_type'] = 't2.micro'
# Version of chef_client to installed
default['buildcluster']['chef_client_version'] = '12.8.1'
#
## How many webservers do we want?
default['buildcluster']['num_web_instances'] = 1
