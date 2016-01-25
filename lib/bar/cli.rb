require 'thor'
require 'yaml'

module Bar
  # CLI tools for running benchmarks
  module CLI
    # The main command-line interface to running benchmarks
    class BarCLI < Thor
      # The path to the configuration file in the working directory
      CONFIG_FILE_NAME = '.bar.yml'

      check_unknown_options!

      private

      # Add the possibility to set defaults via configuration
      def options
        return @options if @options_parsed
        options = super
        config_path = File.join(File.dirname(__FILE__),
                                '../..', CONFIG_FILE_NAME)
        return options unless File.exist? config_path

        defaults = YAML.load_file(config_path).deep_symbolize_keys || {}
        options = defaults.merge_with_arrays(options)
        @options = Thor::CoreExt::HashWithIndifferentAccess.new(options)
        @options_parsed = true

        @options
      end
    end
  end
end

require_relative 'cli/bench'
