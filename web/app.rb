require 'sinatra/base'
require 'warden'

require_relative '../lib/csv_export'

module CsvExport
  class App < Sinatra::Base

    enable :sessions

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


    get "/domains" do
      env["warden"].authenticate!
      account = env["warden"].user

      @domains = CsvExport.account_service.get_account_domains(account.id)

      haml :csv
    end

    post "/domains" do
      env["warden"].authenticate!
      account = env["warden"].user

      domains = CsvExport.account_service.get_account_domains(account.id)

      content_type "application/csv"

      CSV.generate(headers: ["Name", "State", "Expiration", "Whois privacy", "Auto renewal"],
                   write_headers: true) do |csv|
        domains.each do |domain|
          csv << [
            domain["name"],
            domain["state"],
            domain["expires_on"],
            domain["private_whois"],
            domain["auto_renew"]
          ]
        end
      end
    end


    get "/callback" do
      account = CsvExport.account_service.authenticate_account(params[:code])
      session["account_id"] = account.id

      redirect "/domains"
    end

    get "/unauthenticated" do
      redirect "/login"
    end

    post "/unauthenticated" do
      redirect "/login"
    end

    get "/login" do
      redirect CsvExport.api_client.authorize_url
    end

    get "/logout" do
      env["warden"].logout
      redirect "/"
    end

    get "/:account_id" do
      env["warden"].authenticate!
    end

    get "/" do
      haml :index
    end

  end
end
