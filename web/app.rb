require 'sinatra/base'

require_relative 'authentication'
require_relative '../lib/csv_export'

module CsvExport
  class App < Sinatra::Base
    include Authentication

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
