require 'listen'
require 'logger'
require 'pathname'

# watch a local directory. mirror local file changes to remote server via curl+WebDAV.
class Mirror
  def initialize(local_dir:, remote_dir:, log_file: nil, basic_auth:)
    log_target = log_file || '/dev/null'
    @log = Logger.new(log_target).tap { |l| l.level = Logger::INFO }

    @local_dir = Pathname.new(local_dir).cleanpath.to_s
    @remote_dir = remote_dir
    @basic_auth = basic_auth
  end

  # start a long-running watch
  def run
    listener = Listen.to(@local_dir) do |modified, added, removed|
      put(modified)
      put(added)
      delete(removed)
    end

    listener.start
    sleep
  end

  # put newly-added or modified files onto the server
  #
  # @param [Array<String>] paths Absolute local paths to files which have been
  #   added to our local_dir. Expected to be within our configured local_dir.
  def put(paths)
    paths.each do |path|
      remote = remote_path(path)
      out = `curl --write-out '%{http_code}' -T #{path} --user #{@basic_auth} #{remote} 2>/dev/null`.chomp
      @log.info "#{out} PUT    #{path} -> #{remote}"
    end
  end

  # delete removed files from the server
  #
  # @param [Array<String>] paths Absolute local paths to files which have been
  #   removed from our local_dir. Expected to be within our configured local_dir.
  def delete(paths)
    paths.each do |path|
      remote = remote_path(path)
      out = `curl --write-out '%{http_code}' -X DELETE --user #{@basic_auth} #{remote} 2>/dev/null`.chomp
      @log.info "#{out} DELETE #{remote}"
    end
  end

  # turn a local absolute path into a remote absolute path
  #
  # @param [String] local_path An absolute path which is within local_dir
  # @return [String] the remote equivalent
  def remote_path(local_path)
    relative = relativize(local_path)
    return if !relative
    sanitized = relative.gsub(/[^a-zA-Z0-9\-_\.\/]/, '-')
    "#{@remote_dir}#{sanitized}"
  end

  # return a local absolute path into a path fragment relative to local_dir
  #
  # @param [String] local_path a local absolute path within local_dir
  # @return [String] the portion of local_path after local_dir has been removed
  def relativize(local_path)
    local_path[@local_dir.size..-1]
  end
end
