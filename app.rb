require 'sinatra/base'

module DnsimpleHeroku
  class App < Sinatra::Base

    CLIENT_ID = "637370e33040bf54"

    after do
        headers({ "X-Frame-Options" => "ALLOWALL" })
    end

    get "/callback" do
      @params = params
      token = params[:code]
      @output = `curl http://localhost:3000/v2/1/contacts?_api=1 -H "Authorization: #{token}"`
      haml :callback
    end

    get "/:account_id" do

      redirect "http://localhost:3000/oauth/authorize?client_id=#{CLIENT_ID}&response_type=code&state=1234567"

    end

  end
end
