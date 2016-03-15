#
# Cookbook Name:: sampleApp-deploy
# Recipe:: database
#

# provisions an RDS database for this instance of this application

include_recipe 'aws-rds'

# from the aws-rds example:

db_info = {
    name:     'myappdb',
    username: 'test_user',
    password: 'test-password'
}
# TODO - fix the above to be optionally pulled from a data_bag named for the app and environment,
# or at least an attribute

# Creates an instance with id 'myappdb'

aws_rds db_info[:name] do
  engine                'postgres'
  db_instance_class     'db.t1.micro'
  allocated_storage     5
  master_username       db_info[:username]
  master_user_password  db_info[:password]
end

# Instance information will be available in the node object `node[:aws_rds]['myappdb']`
# Since this attribute is set during the `execution` phase of the cookbook,
# you'll need to use Lazy Attribute Evaluation to set the template variable during `execute` phase using `lazy` block

template "/some/place/to/stored_db_creds" do
  variables lazy {
    {
        host:     node[:aws_rds][db_info[:name]][:endpoint_address],
        adapter:  'postgresql',
        encoding: 'unicode',
        database: db_info[:name],
        username: db_info[:username],
        password: db_info[:password]
    }
  }
end

# make sure we have the latest version of the deployable schema
# TODO replace most of these parameters with attributes
aws_s3_file '/tmp/sampleApp/db_restore.tar.gz' do
  bucket 'i_haz_an_s3_buckit'
  remote_path 'path/in/s3/bukket/to/foo'
  region 'us-west-1'
  # add only_if using the remote_file since_last_modified trick to cut down on traffic
end

# maybe use the postgres cookbook to install the client? Or just install a postgres package
# then upload the schema ONLY IF the named database does not exist/is not initialized.
# parallalize the workload according to however many cpus the provisioning node has
execute "initializing empty RDS instance from backup" do
  command "pg_restore db_info[:name] --clean --create -w --jobs #{node[:cpu][:total]} " +
              "--host #{node[:aws_rds][db_info[:name]][:endpoint_address]} " +
              "/tmp/sampleApp/db_restore.tar.gz"
  returns [0, 1]  # also accept a series of "I can't connect" return codes, whatever those may be
  # look in ../libraries for the below functions
  only_if { i_can_connect_to_the_db && the_requested_db_does_not_already_exist }
end