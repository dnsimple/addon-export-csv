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

    def domains(account_id, access_token)
      get("/#{account_id}/domains", access_token)
    end

    private

    def get(path, access_token)
      query   = { "_api" => "1" }
      headers = { "Authorization" => "Bearer #{access_token}" }
      HTTParty.get("#{base_url}#{path}", query: query, headers: headers)
    end

    def base_url
      "#{@url}:#{@port}/v2"
    end
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

      if $accounts.has_key?(account_id)
        redirect "/domains/#{account_id}/csv"
      else
        redirect @api_client.authorize_url
      end
    end

  end
end
