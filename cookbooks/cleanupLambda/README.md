# cleanupLambda

This cookbook installs a lambda function to clean up chef objects after their associated instances are terminated

It will:

1. use the ChefMasterKey CMK to encrypt the user's pem file
2. install the lambda that deletes clients and nodes, bundling with it the user pem file
3.

Notes: 

You should really have a provisioning user to do this, not your generic workstation user.

This recipe could be vastly improved by turning the lazily written execute resources into something
more elegant.
