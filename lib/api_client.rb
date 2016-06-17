require 'httparty'
require 'dnsimple'

class ApiClient
  attr_reader :client_id, :client_secret

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end

  def authorize_url(state: nil)
    options = {state: state} if state
    client  = Dnsimple::Client.new
    client.oauth.authorize_url(client_id, options)
  end

  def authorization(code, state: nil)
    options = {state: state} if state
    client = Dnsimple::Client.new
    client.oauth.exchange_authorization_for_token(code, client_id, client_secret, options)
  end

  def domains(account_id, access_token)
    client = Dnsimple::Client.new(access_token: access_token)
    client.domains.all_domains(account_id).data
  end

end
