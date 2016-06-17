require 'httparty'
require 'dnsimple'

class ApiClient
  attr_reader :client_id, :client_secret

  def initialize(host, port, client_id, client_secret)
    @host = host
    @port = port
    @client_id = client_id
    @client_secret = client_secret
  end

  def authorize_url(state: "12345678")
    client = Dnsimple::Client.new
    client.oauth.authorize_url(client_id, state: state)
  end

  def authorization(code, state: "12345678")
    client = Dnsimple::Client.new
    client.oauth.exchange_authorization_for_token(code, client_id, client_secret, state: state)
  end

  def domains(account_id, access_token)
    client = Dnsimple::Client.new(access_token: access_token)
    client.domains.all_domains(account_id).data
  end

end
