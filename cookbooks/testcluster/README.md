# testcluster

This cookbook sets up a testcluster in AWS using chef-provisioning.

In order to run this cookbook, you must first do the following:
1a. Create the .aws/credentials file in ~/ OR
1b. Fix CF template to deploy a workstation with a IAM role that has both:
    - AmazonEC2FullAccess
    - AmazonVPCFullAccess

2. Add in your chef credentials into the stooges and 3x(nyuk) recipes

To build the cluster, run the following command:
 $ chef-client --local-mode --runlist 'recipe[testcluster::stooges]'

To destroy the cluster, run:
 $ chef-client --local-mode --runlist 'recipe[testcluster::nyuknyuknyuk]'
