require 'sinatra/base'
require 'httparty'

module DnsimpleHeroku
  class ApiClient
    def initialize(url, port, client_id, client_secret)
      @url = url
      @port = port
      @client_id = client_id
      @client_secret = client_secret
    end

    def authorize_url
      "#{@url}:#{@port}/oauth/authorize?client_id=#{@client_id}&response_type=code&state=1234567"
    end

    def authorization(code)
      body = { client_id: @client_id, client_secret: @client_secret, code: code, state: "1234567" }
      auth = HTTParty.post("#{@url}:#{@port}/oauth/access_token", body: body)

      Auth.new(auth["account_id"].to_s, auth["access_token"].to_s)
    end

    def domains(account_id, access_token)
      query    = { "_api" => "1" }
      headers  = { "Authorization" => "Bearer #{access_token}" }
      response = HTTParty.get("#{@url}:#{@port}/v2/#{account_id}/domains", query: query, headers: headers)
      response["data"]
    end

    Auth = Struct.new(:account_id, :access_token)
  end


  class App < Sinatra::Base

    API_ENDPOINT = "http://localhost"
    API_PORT = "3000"
    CLIENT_ID = "58cfec7705d10221"
    CLIENT_SECRET = "h3YtB5rX0hL1mzkiUP1sN7Z6dMFiWqDf"

    $accounts = {}

    before do
      @api_client = ApiClient.new(API_ENDPOINT, API_PORT, CLIENT_ID, CLIENT_SECRET)
    end

    after do
      headers({ "X-Frame-Options" => "ALLOWALL" })
    end

    get "/domains/:account_id" do
    end

    get "/domains/:account_id/csv" do
      account_id = params[:account_id]
      access_token = $accounts[account_id] or halt 403

      domains = @api_client.domains(account_id, access_token)

      csv = CSV.generate do |csv|
        domains.each do |domain|
          csv << [ domain["id"], domain["name"] ]
        end
      end

      haml csv
    end

    get "/callback" do
      auth = @api_client.authorization(params[:code])

      @account_id = auth.account_id
      $accounts[@account_id] = auth.access_token

      haml :callback
    end

    get "/:account_id" do
      account_id = params[:account_id].to_s

      if $accounts.has_key?(account_id)
        redirect "/domains/#{account_id}/csv"
      else
        redirect @api_client.authorize_url
      end
    end

  end
end
