require 'httparty'

class ApiClient
  def initialize(host, port, client_id, client_secret)
    @host = host
    @port = port
    @client_id = client_id
    @client_secret = client_secret
  end

  def authorize_url
    "http://#{@host}:#{@port}/oauth/authorize?client_id=#{@client_id}&response_type=code&state=1234567"
  end

  def authorization(code)
    body = { client_id: @client_id, client_secret: @client_secret, code: code, state: "1234567" }
    response = HTTParty.post("http://#{@host}:#{@port}/oauth/access_token", body: body)

    if response.success?
      Auth.new(response["account_id"].to_s, response["access_token"].to_s)
    else
      raise RuntimeError, "API call failed: #{response["message"]}"
    end
  end

  def domains(account_id, access_token)
    headers  = { "Authorization" => "Bearer #{access_token}" }
    response = HTTParty.get("http://api.#{@host}:#{@port}/v2/#{account_id}/domains", headers: headers)
    response["data"]
  end

  Auth = Struct.new(:account_id, :access_token)

end
