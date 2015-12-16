require 'warden'

module Authentication
  module AuthenticationHelpers
    def current_account
      warden.user
    end

    def authenticate!
      warden.authenticate!
    end

    def logout
      warden.logout
    end

    def warden
      env['warden']
    end
  end


  def self.included(base)
    base.instance_eval do

      helpers AuthenticationHelpers

      use Rack::Session::Cookie

      use Warden::Manager do |manager|
        manager.default_strategies :default
        manager.failure_app = self
      end

      Warden::Strategies.add(:default) do
        def authenticate!
          account = CsvExport.account_service.get_account(session[:account_id])
          success!(account)
        rescue CsvExport::Errors::NotFound
          fail!
        end
      end

      Warden::Manager.serialize_into_session do |account|
        account.id
      end

      Warden::Manager.serialize_from_session do |account_id|
        CsvExport.account_service.get_account(account_id)
      end
    end
  end

end
