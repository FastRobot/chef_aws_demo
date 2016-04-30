# Chef marketplace AWS demo

This is a code demonstration of one way to use Chef and AWS in a harmonious fashion.

It uses a CloudFormation template to build a licensed Chef server using the marketplace AMI as well as
an Ubuntu 14.04 workstation. 
The server is preconfigured with your account and new organization and lives behind an EIP. 

The workstation is automatically linked to the chef server, pulls down some sample cookbooks and repos, 
and uploads cookbooks to your server. You can login to the workstation and run knife commands without 
needing to perform any additional configuration.

From there you may explore a sample web application backed by a redis datastore, and test changes locally 
using test kitchen. 

Once you happy with your tested changes, you can use a different cookbook to automatically deploy that
app to EC2 instances that chef will provision for you, put into different secure subnets and register 
with an ELB for redundancy.
 
## Usage 

Go to the AWS cloudformation console in any region and build a stack from the 
included Chef-Server-Workstation.template.

Fill out all the parameters.

On the final launch page, don't forget to OK the creation of IAM roles via the checkbox at the bottom.

Find the public hostname or IP of the ChefWorkstation machine and ssh into it as user ubuntu, 
using the key you specified when you created the above stack

```
$ ssh -A ubuntu@ec2-52-38-105-203.us-west-2.compute.amazonaws.com  
Welcome to Ubuntu 14.04.4 LTS (GNU/Linux 3.13.0-83-generic x86_64)  
...  
Last login: Tue Apr 12 21:26:23 2016  
ubuntu@ip-172-31-2-78:~$ cd chef-repo/  
ubuntu@ip-172-31-2-78:~/chef-repo$ knife client list  
myorg-validator  
```

cd to the cookbooks/sampleApp directory and run kitchen test to verify the app's correctness via the ec2 driver:

```
ubuntu@ip-172-31-2-78:~/chef-repo$ cd cookbooks/sampleApp
ubuntu@ip-172-31-2-78:~/chef-repo/cookbooks/sampleApp$ kitchen test
-----> Starting Kitchen (v1.6.0)
-----> driver_plugin: ec2
-----> Cleaning up any prior instances of <default-ubuntu-1404>
...
       EC2 instance <i-fb9d8d3c> ready.
       Waiting for SSH service on ec2-52-33-116-18.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
       Waiting for SSH service on ec2-52-33-116-18.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
       Waiting for SSH service on ec2-52-33-116-18.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
       [SSH] Established
...
       Starting Chef Client, version 12.8.1
       Creating a new client identity for default-ubuntu-1404 using the validator key.
       resolving cookbooks for run list: ["sampleApp::default"]
...
       Chef Client finished, 42/58 resources updated in 01 minutes 04 seconds
       Finished converging <default-ubuntu-1404> (1m53.19s).
...
-----> serverspec installed (version 2.31.1)
       /opt/chef/embedded/bin/ruby -I/tmp/verifier/suites/serverspec -I/tmp/verifier/gems/gems/rspec-support-3.4.1/lib:/tmp/verifier/gems/gems/rspec-core-3.4.4/lib /opt/chef/embedded/bin/rspec --pattern /tmp/verifier/suites/serverspec/\*\*/\*_spec.rb --color --format documentation --default-path /tmp/verifier/suites/serverspec

       Port "9000"
         should be listening
         should be listening with tcp

       Command "wget -qO- http://localhost:9000"
         stdout
           should match /This page has been accessed [0-9]+ times/

       Command "wget -qO- http://localhost:80"
         stdout
           should match /This page has been accessed [0-9]+ times/

       Finished in 0.11535 seconds (files took 0.26965 seconds to load)
       4 examples, 0 failures

       Finished verifying <default-ubuntu-1404> (0m8.37s).
-----> Destroying <default-ubuntu-1404>...
       EC2 instance <i-fb9d8d3c> destroyed.
       Finished destroying <default-ubuntu-1404> (0m0.54s).
       Finished testing <default-ubuntu-1404> (3m12.54s).
-----> Kitchen is finished. (3m13.11s)
ubuntu@ip-172-31-2-78:~/chef-repo/cookbooks/sampleApp$
```

You could have also cloned the repo to your local computer and run the same kitchen test, which would have noted 
the lack of AWS/EC2 environment variables and used the vagrant driver instead.

Finally, happy with the above deployment and tests, go ahead and run 

```
ubuntu@ip-172-31-2-78:~/chef-repo$ chef-client --local-mode -r buildcluster
```



# Behind the scenes

The cloudformation accomplishes the following

1. Starts the proper Chef Server AMI from the Marketplace based on your region. If you're in one of the
two regions that support the FlexPricing AMI, it chooses that AMI, otherwise it picks one based on the 
number of nodes you selected.
2. Uses the parameters you supplied to create a user and organization on the chef server
3. Waits till that chef server finishes the upgrade and installation (takes about 25 minutes)
4. Creates a workstation box, assigns it very permissive IAM roles and policies
5. The Workstation downloads the knife credentials from your chef server and clones some cookbooks down
6. All done, login to the workstation as user ubuntu and cd to the chef-repo directory.

TODO
rename buildcluster to sampleAppDeploy and put in public repo
add berks install/upload to cf template

