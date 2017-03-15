Backburner.configure do |config|
  config.beanstalk_url = "beanstalk://127.0.0.1"
  config.tube_namespace = "sampleblog.jobs"
  config.on_error = lambda { |e| puts(e) }
end
