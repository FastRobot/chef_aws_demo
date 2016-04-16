# sampleApp-deploy

This cookbook is for deploying the sampleApp to AWS, creating the necessary infrastructure (ELB, VPCs, gateways)

We're choosing to separate this from the sampleApp cookbook but you might have chosen to do something similar in a
yourApp::deploy recipe.

recipe[sampleApp-deploy::default] will build a full stack, named after the environment the provisioning node is in. 

recipe[sampleApp-deploy::instance] is meant to be called on the run_list of the node running each app. It will 
register the node it is running on into the appropriate ElasticLoadBalancer pool and tag itself appropriately.

recipe[sampleApp-deploy::database] is called in the default recipe but broken out for readablity and future refactoring


