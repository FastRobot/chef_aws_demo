
Manual steps

aws config: setup, took all defaults
  watch all resources, create new bucket (config-bucket-668763449349), publish to SNS topic "config-topic"
  it asked to create a IAM role for me, config-role

sns: create topic arn:aws:sns:us-west-2:668763449349:fr_aws_test (display name aws_test)
 (not currently using, plan on filtering/sending some messages through a test lambda later)
 (later launched sns-message to watch config-topic, created a new iam role lambda_basic_execution)
 
cloudformation:
  launched template designer
  
ec2:
  launched instance, ami-087e9d68 on a t2.medium
  ec2-user@ip-172-31-42-95 ~]$ sudo chef-marketplace-ctl setup --yes --eula --register -u lamont -p foobar \
    -f lamont -l lucas -e lamont@fastrobot.com -o testorg  
    (took 12 minutes)
    

Documentation on chef-marketplace-ctl command (trying to figure out preconfigure)
https://github.com/chef-partners/omnibus-marketplace

what manner of curl does it take to get the starter.zip?
captured a .har, post to getting_started url with a token

curl 'https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com/organizations/testorg/getting_started' -H 'Cookie: chef-manage=6135ea49eeb26a302bb947751baf4342' -H 'Origin: https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://ec2-52-37-68-186.us-west-2.compute.amazonaws.com/organizations/testorg/getting_started' -H 'Connection: keep-alive' --data 'authenticity_token=TnzipjMq7DeadquJ9CRbXPpk8OisYWoiWtqUcTlazOtqaUSVHmcUW4ujBwKWWqLDXPtDafu%2FXIoXpVSF0%2FPOPQ%3D%3D' --compressed --insecure
captured a .har, post to getting_started url with a token

Getting_Started:
The ruby script getting_started.rb will automatically download the chef-started.zip.  It should be invoked with the embedded ruby in the chefdk.
It takes 4 arguments in the following order: <chef_server_url> <orgname> <username> <password>


if I can export cloudformation as json, I can import it and re-template it, so theoretically I could have a chef local
recipe that spits out the cloudformation.json with whatever customizations I want. 
