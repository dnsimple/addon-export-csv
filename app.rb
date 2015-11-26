require 'sinatra/base'

module DnsimpleHeroku
  class App < Sinatra::Base

    CLIENT_ID = "637370e33040bf54"

    get '/:account_id' do

      redirect "http://localhost:3000/oauth/authorize?client_id=#{CLIENT_ID}&response_type=code&state=1234567"

    end

  end
end
