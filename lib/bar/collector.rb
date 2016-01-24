require 'net/ssh'

module Bar
  # Collect the output of a set of commands and files from a remote host
  class Collector
    attr_reader :command

    def initialize(command)
      @command = command
    end

    # Collect output from running the command on a single host
    def collect(host)
      ssh = Net::SSH.start(host)
      output = ssh.exec!(@command)
      ssh.close

      output
    end
  end
end
