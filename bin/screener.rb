# watch screenshot directory
# when a file matches a desired pattern, rename it and move it to the mirror directory.

require 'securerandom'
require 'pathname'
require_relative '../lib/mirror.rb'

config = Mirror.read_config
mirror = Mirror.new(config)

#https://www.launchd.info/
# directory containing screenshots
from_dir = Pathname.new(ARGV[0])
# path inside a directory being watched by mirror
to_dir = Pathname.new(ARGV[1])
# files in from_dir matching this glob will be moved.
matching_glob = 'up*'

Dir["#{from_dir}/#{matching_glob}"].each do |file|
  ext = File.extname(file)
  new_name = File.mtime(file).strftime('%Y%m%d-%H%M') + '-' + SecureRandom.hex(4) + ext
  to_path = to_dir.join(new_name).to_s
  mirror.log.info "screener: mv '#{file}' -> '#{to_path}'"
  FileUtils.mv file, to_path
  `echo #{mirror.remote_path(to_path)} | pbcopy`
end
