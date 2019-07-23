if !ARGV[0].nil?
  require_relative '../lib/mirror.rb'
  config = Mirror.read_config
  mirror = Mirror.new(config)
  puts mirror.remote_path(ARGV[0])
end
