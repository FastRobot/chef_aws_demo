#
## Edit this block on the top if you want a different AWS Region, or
## have manually installed the .chef directory outside /home/ubuntu/chef-repo/.chef
# PATH to your .chef directory from the chef-starter.zip
default['buildcluster']['chef_dir'] = '/home/ubuntu/chef-repo/.chef'
# the AWS location (default is us-west-2)
default['buildcluster']['aws_region'] = ENV['AWS_DEFAULT_REGION'] || 'us-west-2'

#
## machine details
# Determine AMI by AWS Region this is the default Ubuntu AMI for us-west-2
# and us-east-1 as of April 30, 2016
default['buildcluster']['image_id'] = node['ec2'].nil? || node['ec2']['ami_id'].nil? ? 'ami-9abea4fb' : node['ec2']['ami_id']
default['buildcluster']['instance_type'] = 't2.micro'

# Version of chef_client to installed
default['buildcluster']['chef_client_version'] = '12.8.1'
# The chef_environment to deploy our nodes into in
default['buildcluster']['chef_environment'] = '_default'

#
## How many webservers do we want?
default['buildcluster']['num_web_instances'] = 2
