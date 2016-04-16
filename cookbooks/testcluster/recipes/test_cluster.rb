machine 'moe' do
  chef_server :chef_server_url => 'https://ec2-52-8-176-65.us-west-1.compute.amazonaws.com/organizations/testorg'
end

machine 'larry' do
  chef_server :chef_server_url => 'https://ec2-52-8-176-65.us-west-1.compute.amazonaws.com/organizations/testorg'
end
