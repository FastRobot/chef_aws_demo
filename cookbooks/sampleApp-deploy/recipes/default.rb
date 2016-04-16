#
# Cookbook Name:: sampleApp-deploy
# Recipe:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

include_recipe "aws"

# The ELB

# The VPCs

# IAM Roles
# this node needs to be able to
#   - create instances
#   - manage IAM roles (which is pretty much giving away the store at this point)
#   - manage RDS
#   - manage VPCs
#   - manage ELBs (membership locked to chef_environment?)
#   - manage tags

# The database on RDS

include_recipe "sampleApp-deploy::database"

# The instances
#  instances add themselves to the ELB