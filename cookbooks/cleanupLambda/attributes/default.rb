
default['cleanupLambda']['chef_dir'] = '/home/ubuntu/chef-repo/.chef'

default['cleanupLambda']['key_id'] = ENV['CHEF_KMS_KEYID']

default['cleanupLambda']['git_repo'] = 'https://github.com/awslabs/lambda-chef-node-cleanup'
default['cleanupLambda']['git_revision'] = 'ca7f6b231dc81a1dd6e6fd27f4fe2b24d4a816af'