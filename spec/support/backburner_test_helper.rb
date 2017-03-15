if Rails.env.test?
  module Backburner
    def self.test_mode
      @test_mode ||= :fake
    end

    def self.test_mode=(mode)
      @test_mode = mode
    end

    def self.test_enqueued_jobs
      @test_enqueued_jobs ||= []
    end

    def self.logger
      @logger ||= Logger.new(Rails.root.join('log/backburner_test.log'))
    end

    def self.test_enqueued_jobs_find_by_argument(arg)
      test_enqueued_jobs.find{|j| Array(j[:args]).include?(arg)}
    end

    def self.test_enqueued_jobs_find_by_job(arg)
      test_enqueued_jobs.find{|j| j[:job].eql?(arg)}
    end

    def self.empty_test_queue!
      @test_enqueued_jobs = []
    end

    def self.enqueue(job, *args)
      if args.last.is_a?(Hash)
        options = args.pop
      else
        options = {}
      end
      if args.size.eql?(1)
        args = args.first
      end
      test_enqueued_jobs << {:job => job.to_s, :args => args, :options => options}
      if test_mode.eql?(:fake)
        true
      elsif test_mode.eql?(:inline)
        job.perform(*args)
      else
        raise "Unknown test_mode : #{test_mode}"
      end
    end

    def self.method_missing(meth, *args, &block)
      logger.debug "Backburner method missing: #{meth} : #{args.inspect}"
    end

    class Worker
      def self.enqueue(job, *args)
        if args.last.is_a?(Hash)
          options = args.pop
        else
          options = {}
        end
        if args.size.eql?(1)
          args = args.first
        end
        Backburner.enqueue(job, args, options)
      end

      def self.logger
        Backburner.logger
      end

      def logger
        Backburner.logger
      end

      def self.method_missing(meth, *args, &block)
        logger.debug "Backburner worker method missing: #{meth} : #{args.inspect}"
      end

      def method_missing(meth, *args, &block)
        logger.debug "Backburner worker instance method missing: #{meth} : #{args.inspect}"
      end
    end

    module Queue
      def self.included(base)
        base.extend ClassMethods
      end
      module ClassMethods
        def queue(value=nil)
        end
        def queue_priority(value=nil)
        end
        def queue_respond_timeout(value=nil)
        end
      end
    end
  end
else
  require 'backburner'
  Backburner.configure do |config|
    config.beanstalk_url    = APP_CONFIG["beanstalk"]["servers"]
    config.tube_namespace   = APP_CONFIG["beanstalk"]["namespace"]
    config.on_error         = lambda { |e| DoubleLogger.new(Rails.root.join("log/backburner.log")).error "#{e.message} #{e.backtrace}" }
    config.max_job_retries  = APP_CONFIG["beanstalk"]["max_retries"]
    config.retry_delay      = APP_CONFIG["beanstalk"]["retry_delay"]
    config.default_priority = 1000
    config.respond_timeout  = 3600
    config.default_worker   = Backburner::Workers::ThreadsOnFork
    config.logger           = DoubleLogger.new(Rails.root.join("log/backburner.log"), :log_level => :warn)
    config.primary_queue    = "backburner-jobs"
  end
  module Backburner
    module Queue
      module ClassMethods
        def logger
          Backburner.configuration.logger
        end
      end
    end
    class Job
      def before_perform
        ActiveRecord::Base.verify_active_connections!
      end

      def after_perform
        ActiveRecord::Base.clear_active_connections!
      end
    end
  end
end
