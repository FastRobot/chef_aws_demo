# Chef marketplace AWS demo

This is a demonstration of one way to use Chef and AWS in a harmonious fashion.

There's a CloudFormation template to build the initial set of a AWS marketplace Chef Server and
linked workstation, then three cookbooks:

* sampleApp - a sinatra ruby app with a redis datastore, testable with kitchen
* buildcluster - a chef provisioning recipe to setup AWS infrastructure and networking and deploy sampleApp
* cleanupLambda - a quick and dirty cookbook to deploy a lambda which will clean terminated instances from the chef server

Use the CloudFormation template to build a licensed Chef server using the marketplace AMI as well as
an Ubuntu 14.04 workstation. 

The server is preconfigured with your account and new organization and lives behind an EIP. 

The workstation is automatically linked to the chef server, pulls down some sample cookbooks and repos, 
and uploads cookbooks to your server. You can login to the workstation and run knife commands without 
needing to perform any additional configuration.

From there you may explore a sample web application backed by a redis datastore, and test changes locally
 (using vagrant or EC2) using test kitchen. 

Once you are happy with your tested changes, you can use a different cookbook to automatically deploy the
sampleApp to EC2 instances that chef will provision for you, put into different secure subnets and register 
with an ELB for redundancy.

Finally, there is an included cleanupLambda cookbook which sets up a lambda process to clean up
chef objects for instances as they are terminated.  the cleanupLambda cookbook is very basic and simply 
attempts to automate the instructions from a previous AWS demo about setting up a lambda
 
## Usage 

Go to the AWS cloudformation console in any region and build a stack from the 
included Chef-Server-Workstation.template.

Fill out all the parameters.

On the pre-launch page, don't forget to OK the creation of IAM roles via the checkbox at the bottom.

Find the public hostname or IP of the ChefWorkstation machine and ssh into it as user ubuntu, 
using the key you specified when you created the above stack. If you'd like buildcluster or test kitchen to work,
you'll need to make sure you're using ssh-agent to serve up your ssh keys and ssh to the workstation instance
with -A to allow further ssh connections access to your agent. 

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

Next, happy with the above deployment and tests, install (stage) the cookbooks to your workstation
and upload the cookbooks to the chef server with these two berks commands from inside the sampleApp:
```
ubuntu@ip-172-31-2-78:~/chef-repo/cookbooks/sampleApp$ berks install
Resolving cookbook dependencies...
Fetching 'sampleApp' from source at .
Using 7-zip (1.0.2)
...
ubuntu@ip-172-31-2-78:~/chef-repo/cookbooks/sampleApp$ berks upload
Uploaded 7-zip (1.0.2) to: 'https://ec2-52-39-174-145.us-west-2.compute.amazonaws.com:443/organizations/myorg'
...
```

Then go ahead and run a local chef-client with the buildcluster cookbook: 

```
ubuntu@ip-172-31-2-78:~/chef-repo$ chef-client --local-mode -r buildcluster
```

To view your new cluster, you'd need to wait 2 minutes until the instances pass their health checks then
go to the ELB url. Don't know the ELB url? Good news, we installed the aws cli toolkit and preconfigured
it to have access to your account:

```
ubuntu@ip-172-31-4-121:~/chef-repo$ aws elb describe-load-balancers --query LoadBalancerDescriptions[0].CanonicalHostedZoneName
"chef-aws-elb-752615793.us-west-2.elb.amazonaws.com"
```

When you are finished with these examples, don't forget to clean up after yourself to prevent unnecessary
charges.

```
ubuntu@ip-172-31-2-78:~/chef-repo$ chef-client --local-mode -r "buildcluster::teardown"
```
Note that the teardown will attempt to destroy all the machines you built via the buildcluster and destroy
the created vpc (named 'chef-aws-vpc') and purge all remaining subnet and network objects in it. Not only will this
kill you, it will hurt the entire time you are dying.

We've also taken the awslabs example lambda to clean up chef objects after instance termination and written
a cookbook around it to automate the install. You can see the original code and readme here:

https://github.com/awslabs/lambda-chef-node-cleanup

To use our wrapper, invoke it in a similar fashion to the buildcluster cookbook

```
ubuntu@ip-172-31-2-78:~/chef-repo$ chef-client --local-mode -r cleanupLambda
```

There's a variable delay between when the terraform creates the chef_node_cleanup_lambda role and when that role
has propagated enough that we can add it to the kms key policy for our ChefMasterKey. We've attempted to account
for this by adding a execute delay block of 30s, but in some tests it took longer and I had to re-run the 
above chef-client/cleanupLambda cookbook. You can see the 404 returned in the ruby block if it fails, or
otherwise you can run

```
ubuntu@ip-172-31-33-119:~/chef-repo$ aws kms get-key-policy --key-id $CHEF_KMS_KEYID --policy default
```

and check that the output contains "arn:aws:iam::ACCOUNT_ID:role/chef_node_cleanup_lambda"

Note that this cookbook relies heavily on environment variables set via user-data when we created the workstation,
so while it runs here, if you wanted to extract the cookbook and use it elsewhere you'd need to clean it up
a bit and carefully look at the assumptions we make as we set attributes.

To test, either create nodes from the build cluster above or manually an additional instance and bootstrap it:

```
ubuntu@ip-172-31-43-49:~/chef-repo$ knife bootstrap -x ec2-user --sudo ec2-52-38-202-117.us-west-2.compute.amazonaws.com
Doing old-style registration with the validation key at /home/ubuntu/chef-repo/.chef/thistrain-validator.pem...
```

Verify that the node was created and registered with the chef server:

```
ubuntu@ip-172-31-43-49:~/chef-repo$ knife node list
ip-172-31-8-25.us-west-2.compute.internal
```

Now delete the node from the AWS console, then verify that the lambda cleaned up the node and client object for
our terminated AWS node. (via knife client list and knife node list)

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

Additionally we've written a basic cookbook wrapper around the lambda for node cleanup, based off
of the excellent work here: 

https://aws.amazon.com/blogs/apn/automatically-delete-terminated-instances-in-chef-server-with-aws-lambda-and-cloudwatch-events/

