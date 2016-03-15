#
# Cookbook Name:: sampleApp
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# from the poise cookbook example
application '/opt/test_sinatra' do
  git 'https://github.com/example/my_sinatra_app.git'
  # TODO: replace with CodeCommit
  bundle_install do
    deployment true
  end
  unicorn do
    port 9000
  end
end
