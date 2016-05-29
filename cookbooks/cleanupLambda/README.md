# cleanupLambda

This cookbook installs a lambda function to clean up chef objects after their associated instances are terminated

It is meant to be run in chef-local mode as a user with a valid .chef directory under ~/chef-repo.

It will:

1. use the ChefMasterKey CMK to encrypt the user's pem file
2. git clone the awslabs/lambda-chef-node-cleanup (or our fork of it till they take our PR)
3. template out a config file, bundling the lambda.zip with it and the encrypted pem
2. install the lambda that deletes clients and nodes via their included terraform
3. modify the ChefMasterKey policy to allow the lambda role to use the key

Notes: 

You should really have a provisioning user to do this, not your generic workstation user.

This recipe could be a lot more robust, but this was enough to improve the installation for most
demo users. Ideally we'd use the aws cookbook to manipulate the IAM roles and policies, or extend
chef provisioning to deal with lambdas.

