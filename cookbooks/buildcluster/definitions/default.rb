#
## Pass in path to .chef directory and this will return the knife
## creds required for chef-provisioning to associate new nodes to
## a remote chef-server (aka not the local chefzero instance)

define :getKnifeCreds do
  creds = Hash.new()

  unless params[:chef_dir].nil?
    knife = params[:chef_dir].strip + "/knife.rb"
    current_dir = File.dirname(knife)
    File.readlines(knife).map do |line|
      k,v = line.scan(/\S+/)
      creds.merge!({k => v.tr('"','')}) if k == 'node_name' || k == 'client_key' || k == 'chef_server_url'
    end
    creds['client_key'].gsub!(/\#\{current_dir\}/, "#{current_dir}")
  end

  creds
end
