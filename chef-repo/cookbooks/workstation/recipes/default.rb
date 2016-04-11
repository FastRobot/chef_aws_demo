#
# Cookbook Name:: workstation
# Recipe:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

# if we don't have the starter.zip AND .chef is not properly configured, let's get the starter.zip

# maybe use this to get our OAUTH token we'll need for the remote_file request
http_request 'posting data' do
  action :post
  url 'http://example.com/check_in'
  message ({:some => 'data'}.to_json)
  headers({'AUTHORIZATION' => "Basic #{
  Base64.encode64('username:password')}",
           'Content-Type' => 'application/data'
          })
end

# captured starter.zip looked like:
# curl 'https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com/organizations/testorg/getting_started'
# -H 'Cookie: chef-manage=6135ea49eeb26a302bb947751baf4342'
# -H 'Origin: https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com'
# -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1'
# -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36'
# -H 'Content-Type: application/x-www-form-urlencoded'
# -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
# -H 'Cache-Control: max-age=0'
# -H 'Referer: https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com/organizations/testorg/getting_started'
# -H 'Connection: keep-alive'
# --data 'authenticity_token=TnzipjMq7DeadquJ9CRbXPpk8OisYWoiWtqUcTlazOtqaUSVHmcUW4ujBwKWWqLDXPtDafu%2FXIoXpVSF0%2FPOPQ%3D%3D'
# --compressed --insecure

remote_file '/var/www/customers/public_html/index.php' do
  source 'http://somesite.com/index.php'
  owner 'web_admin'
  group 'web_admin'
  mode '0755'
  action :create
end

# install the aws-cli tools via the aws-cli cookbook

# maybe setup the lambda for reaping chef nodes?

# make sure kitchen/docker is setup (if we're using docker)

# git installed?

