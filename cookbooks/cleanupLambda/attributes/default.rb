
default['cleanupLambda']['chef_dir'] = '/home/ubuntu/chef-repo/.chef'

default['cleanupLambda']['key_id'] = ENV['CHEF_KMS_KEYID']

#default['cleanupLambda']['git_repo'] = 'https://github.com/awslabs/lambda-chef-node-cleanup'
default['cleanupLambda']['git_repo'] = 'https://github.com/FastRobot/lambda-chef-node-cleanup.git'
default['cleanupLambda']['git_revision'] = '9e76f3acf90fca53527ca6f3f11d09df3ebfac75'