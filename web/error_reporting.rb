require 'bugsnag'

module ErrorReporting
  Bugsnag.configure do |config|
    config.api_key = ""
  end

  def self.included(base)
    base.instance_eval do
      use Bugsnag::Rack
      enable :raise_errors
    end
  end
end
