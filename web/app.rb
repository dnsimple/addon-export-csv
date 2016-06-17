require 'sinatra/base'

require_relative 'authentication'
require_relative 'error_reporting'

require_relative '../lib/csv_export'

module CsvExport
  class App < Sinatra::Base
    include Authentication
    include ErrorReporting

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
      CsvExport.account_service.get_account_domains_as_csv(current_account.id)
    end

    get "/callback" do
      account = CsvExport.account_service.authenticate_account(params[:code], state: session[:oauth_state])
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
      redirect CsvExport.api_client.authorize_url(state: oauth_state)
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


    private

    def oauth_state
      session[:oauth_state] = Digest::MD5.hexdigest(rand(100000).to_s)
    end

  end
end
