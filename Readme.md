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