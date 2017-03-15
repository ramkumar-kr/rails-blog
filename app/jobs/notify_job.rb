class NotifyJob
  # required
  def self.perform(article)
    puts "Notifying people..."
  end

  # optional, defaults to 'backburner-jobs' tube
  def self.queue
    "notify_subscribers"
  end

  # optional, defaults to default_priority
  def self.queue_priority
    1000
  end

  # optional, defaults to respond_timeout
  def self.queue_respond_timeout
    300
  end
end
