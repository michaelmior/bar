require 'aruba/api'
require 'aruba/in_process'
require 'aruba/reporting'

require 'bar/cli'

module Bar
  module CLI
    class BarCLI
      TEST_CONFIG_FILE_NAME = File.join File.dirname(__FILE__), '..', '..',
                                        'bar.yml.example'

      def initialize(*args)
        suppress_warnings do
          BarCLI.const_set 'CONFIG_FILE_NAME', TEST_CONFIG_FILE_NAME
        end

        super(*args)
      end

      # Override so we don't look like RSpec
      def self.basename
        'bar'
      end
    end

    # Runner for use with tests
    class Runner
      # Allow everything fun to be injected from the outside
      # while defaulting to normal implementations.
      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR,
                     kernel = Kernel)
        @argv = argv
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @kernel = kernel
      end

      # Execute the app using the injected stuff
      # https://git.io/vzotl
      # rubocop:disable Metrics/MethodLength
      def execute!
        exit_code = begin
                      # Thor accesses these streams directly rather than
                      # letting them be injected, so we replace them...
                      $stderr = @stderr
                      $stdin = @stdin
                      $stdout = @stdout

                      # Run our normal Thor app the way we know and love.
                      Bar::CLI::BarCLI.start @argv

                      # Thor::Base#start does not have a return value,
                      # assume success if no exception is raised.
                      0
                    rescue StandardError => e
                      # The Ruby interpreter would pipe this to STDERR
                      # and exit 1 in the case of an unhandled exception
                      b = e.backtrace
                      @stderr.puts "#{b.shift}: #{e.message} (#{e.class})"
                      @stderr.puts b.map { |s| "\tfrom #{s}" }.join("\n")
                      1
                    rescue SystemExit => e
                      e.status
                    ensure
                      $stderr = STDERR
                      $stdin = STDIN
                      $stdout = STDOUT
                    end

        # Proxy our exit code back to the injected kernel.
        @kernel.exit exit_code
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = Bar::CLI::Runner
end

RSpec.configure do |config|
  config.include Aruba::Api

  config.before(:each) do
    setup_aruba
  end
end
