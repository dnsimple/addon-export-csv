require 'sinatra/base'
require 'httparty'

module DnsimpleHeroku
  class App < Sinatra::Base

    CLIENT_ID = "637370e33040bf54"
    CLIENT_SECRET = "Rxb0fPyiCY2onYRyUStaZvwZww8SzgaB"

    $accounts = {}

    after do
      headers({ "X-Frame-Options" => "ALLOWALL" })
    end


    get "/domains/:account_id" do
    end

    get "/domains/:account_id/csv" do
      account_id = params[:account_id]
      access_token = $accounts[account_id] or halt 403

      domains = HTTParty.get("http://localhost:3000/v2/#{account_id}/domains",
        query: { "_api" => "1" },
        headers: { "Authorization" => "Bearer #{access_token}"
      })

      csv = CSV.generate do |csv|
        domains["data"].each do |domain|
          csv << [ domain["id"], domain["name"] ]
        end
      end

      haml csv
    end

    get "/callback" do
      oauth = HTTParty.post("http://localhost:3000/oauth/access_token", body: {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        code: params[:code],
        state: "1234567"
      })

      @account_id = oauth["account_id"].to_s
      access_token = oauth["access_token"].to_s
      $accounts[@account_id] = access_token

      haml :callback
    end

    get "/:account_id" do
      account_id = params[:account_id].to_s

      puts $accounts
      puts account_id
      puts $accounts[account_id].inspect
      puts $accounts.has_key?(account_id)

      if $accounts.has_key?(account_id)
        redirect "/domains/#{account_id}/csv"
      else
        redirect "http://localhost:3000/oauth/authorize?client_id=#{CLIENT_ID}&response_type=code&state=1234567"
      end
    end

  end
end
