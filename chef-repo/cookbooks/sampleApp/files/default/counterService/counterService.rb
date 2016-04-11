require 'sinatra'
require 'redis'
require "sinatra/config_file"

config_file 'config.yml'

set :bind, '0.0.0.0'
$Redis = Redis.new(host: settings.redis_host, port: 6379)


get '/' do
  count = $Redis.incr( "request_count" )
  "This is request #{count}\n"
end
