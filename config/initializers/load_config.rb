# use config file from host app as default
config_file = Rails.root.join('config', 'lines_config.yml')

# use engine's config file if not exists in host app
unless File.exist?(config_file)
  config_file = Lines::Engine.root.join('config', 'lines_config.yml')
end

# Load the configuration
CONFIG = YAML.safe_load(ERB.new(File.read(config_file)).result(binding))
CONFIG.merge! CONFIG.fetch(Rails.env, {})
CONFIG.symbolize_keys!
