require 'active_support/core_ext/hash'
require 'dotenv'
Dotenv.load

module VAMS
  module Environment
    extend self
    CONFIG_PATH = File.join(__dir__, 'config.yml')
    class InvalidEnvironmentError < RuntimeError
    end

    def construct(env)
      env_config = config[env.to_s]
      raise InvalidEnvironmentError.new("environment #{env} is invalid. Valid environments are: #{config.keys.join(', ')}.") unless env_config
      hash = config[env.to_s].merge(secrets(env.to_s))
      hash = hash.symbolize_keys
      OpenStruct.new(hash)
    end

    private

    def config
      @config ||= YAML.load_file(CONFIG_PATH)
    end

    def secrets(env)
      username = ENV["#{env.to_s.upcase}_VAMS_USER"]
      password = ENV["#{env.to_s.upcase}_VAMS_PASSWORD"]
      { username: username, password: password }
    end
  end
end
