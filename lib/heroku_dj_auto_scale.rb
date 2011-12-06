require 'heroku'
require 'delayed_job'

module HerokuDjAutoScale
  module Scaler
    class << self
      
      def heroku
        @heroku ||= Heroku::Client.new(ENV['HEROKU_USER'], ENV['HEROKU_PASS']) if ENV['USE_HEROKU_SCALING'] == 'true'
      end
      
      def stack
        if ENV['USE_HEROKU_SCALING'] == 'true'
          heroku.list_stacks(ENV['HEROKU_APP']).inject("") do |current,stack| 
            stack["current"] ? stack["name"] : current
          end
        else
          "current"
        end
      end
      
      def get_workers
        if ENV['USE_HEROKU_SCALING'] == 'true'
          if stack == "cedar"
            heroku.ps(ENV['HEROKU_APP']).count { |p| p["process"] =~ /worker\.\d?/ }
          else
            heroku.info(ENV['HEROKU_APP'])[:workers].to_i
          end
        else
          1
        end
      end
      
      def workers=(qty)
        if ENV['USE_HEROKU_SCALING'] == 'true'
          if stack == "cedar"
            heroku.ps_scale(ENV['HEROKU_APP'], :type => 'worker', :qty => qty)
          else
            heroku.set_workers(ENV['HEROKU_APP'], qty)
          end
        end
      end

      def job_count
        Delayed::Job.all.count.to_i
      end
      
      def job_count_unlocked
        Delayed::Job.where(:locked_by => nil).count.to_i
      end
    end
  end

  def completed(*args)
    # Nothing fancy, just shut everything down if we have no jobs
    Scaler.workers = 0 if Scaler.job_count.zero? 
  end

  def enqueue(*args)
    [
      {
        :workers => 1, # This many workers
        :job_count => 1 # For this many jobs or more, until the next level
      },
      {
        :workers => 1,
        :job_count => 400
      },
      {
        :workers => 1,
        :job_count => 2500
      }
    ].reverse_each do |scale_info|
      # Run backwards so it gets set to the highest value first
      # Otherwise if there were 70 jobs, it would get set to 1, then 2, then 3, etc

      # If we have a job count greater than or equal to the job limit for this scale info
      if Scaler.job_count >= scale_info[:job_count]
        # Set the number of workers unless they are already set to a level we want. Don't scale down here!
        if Scaler.workers <= scale_info[:workers]
          Scaler.workers = scale_info[:workers]
        end
        break # We've set or ensured that the worker count is high enough
      end
    end
  end
end
