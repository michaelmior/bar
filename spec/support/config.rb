require 'yaml'

module ConfigHelper
  def use_config(config)
    config_file = File.join(File.dirname(__FILE__),
                            '../..', Bar::CLI::BarCLI::CONFIG_FILE_NAME)
    File.open(config_file, 'w') { |f| f.write(config.to_yaml) }
  end
end
