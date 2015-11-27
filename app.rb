require 'sinatra/base'
require 'httparty'

module DnsimpleHeroku
  class App < Sinatra::Base

    CLIENT_ID = "637370e33040bf54"
    CLIENT_SECRET = "Rxb0fPyiCY2onYRyUStaZvwZww8SzgaB"

    after do
        headers({ "X-Frame-Options" => "ALLOWALL" })
    end

    get "/callback" do
      @params = params
      token = params[:code]

      options = { client_id: CLIENT_ID,
                  client_secret: CLIENT_SECRET,
                  code: params[:code],
                  redirect_uri: "http://fast-wave-9818.herokuapp.com/access_token",
                  state: "1234567" }

      response = HTTParty.get("http://localhost:3000/oauth/access_token",
                             query: options)
      haml :callback
    end

    get "/" do
      redirect "http://localhost:3000/oauth/authorize?client_id=#{CLIENT_ID}&response_type=code&state=1234567"
    end

    get "/access_token" do
      @params = params
      haml :access_token
    end

  end
end
