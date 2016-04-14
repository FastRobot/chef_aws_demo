#
## Edit this block on the top if you want a different AWS Region, or
## have manually installed the .chef directory outside /home/ubuntu/chef-repo/.chef
# the AWS location (default is us-west-1)
default['buildcluster']['aws_region'] = 'us-west-1'
# PATH to your .chef directory from the chef-starter.zip
default['buildcluster']['chef_dir'] = '/Users/jcook/fastrobot/AWS/.chef'
# The chef_environment to deploy our nodes into in
default['buildcluster']['chef_environment'] = 'chef_aws_demo'

#
## How many webservers do we want?
default['buildcluster']['num_web_instances'] = 1
