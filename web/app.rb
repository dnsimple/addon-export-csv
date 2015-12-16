require 'sinatra/base'

require_relative '../lib/csv_export'

module CsvExport
  class App < Sinatra::Base

    get "/domains/:account_id/csv" do
      account = CsvExport.account_service.get_account(params[:account_id]) or halt 403
      @domains = CsvExport.account_service.get_account_domains(account.id)

      haml :csv
    end

    post "/domains/:account_id/csv" do
      account = CsvExport.account_service.get_account(params[:account_id]) or halt 403
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
      CsvExport.account_service.authenticate_account(params[:code])

      redirect "/domains/#{auth.account_id}/csv"
    end

    get "/:account_id" do
      begin
        account = CsvExport.account_service.get_account(params[:account_id])
        redirect "/domains/#{account.id}/csv"
      rescue CsvExport::Errors::NotFound
        haml :index
      end
    end

    get "/" do
      haml :index
    end

  end
end
