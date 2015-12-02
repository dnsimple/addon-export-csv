require 'sinatra/base'

require_relative '../lib/account'
require_relative '../lib/account_storage'
require_relative '../lib/api_client'

class CsvExportAddon < Sinatra::Base

  before do
    @accounts   = RedisAccountStorage.new
    @api_client = ApiClient.new(
      ENV["API_ENDPOINT"],
      ENV["API_PORT"],
      ENV["CLIENT_ID"],
      ENV["CLIENT_SECRET"]
    )
  end

  after do
    headers({ "X-Frame-Options" => "ALLOWALL" })
  end


  get "/domains/:account_id/csv" do
    account = @accounts.get(params[:account_id]) or halt 403
    @domains = @api_client.domains(account.id, account.access_token)

    haml :csv
  end

  post "/domains/:account_id/csv" do
    account = @accounts.get(params[:account_id]) or halt 403
    domains = @api_client.domains(account.id, account.access_token)

    content_type "application/csv"

    CSV.generate do |csv|
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
    auth = @api_client.authorization(params[:code])

    @accounts.store(Account.new(auth.account_id, auth.access_token))

    redirect "/domains/#{auth.account_id}/csv"
  end

  get "/:account_id" do
    if account = @accounts.get(params[:account_id])
      redirect "/domains/#{account.id}/csv"
    else
      haml :index
    end
  end

end
