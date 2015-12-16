require 'sinatra/base'

require_relative 'authentication'
require_relative '../lib/csv_export'

module CsvExport
  class App < Sinatra::Base
    include Authentication

    set :public_folder, Proc.new { File.join(root, "public") }

    get "/domains" do
      authenticate
      @domains = CsvExport.account_service.get_account_domains(current_account.id)
      haml :csv
    end

    post "/domains" do
      authenticate

      content_type "application/csv"
      attachment "account-domains.csv"

      CSV.generate(write_headers: true, headers: [
        "Name",
        "State",
        "Expiration",
        "Whois privacy",
        "Auto renewal"
      ]) do |csv|
        domains = CsvExport.account_service.get_account_domains(current_account.id)
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
      logout
      redirect "/"
    end

    get "/:account_id" do
      authenticate
    end

    get "/" do
      haml :index
    end

  end
end
