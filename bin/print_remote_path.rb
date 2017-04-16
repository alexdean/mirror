if !ARGV[0].nil?
  require 'yaml'
  this_dir = File.dirname(File.realpath(__FILE__))
  config = YAML.load(File.read("#{this_dir}/../config.yml"))
  require_relative '../lib/mirror.rb'

  mirror = Mirror.new(config)
  puts mirror.remote_path(ARGV[0])
end
