require 'pyroscope'

Pyroscope.configure do |config|
  config.application_name = "railsgoat"
  # config.server_address = "http://localhost:4040"
  config.server_address = ENV["PYROSCOPE_URL"]
  config.autoinstrument_rails = false
  config.detect_subprocesses = true
  config.sample_rate = 20
end
