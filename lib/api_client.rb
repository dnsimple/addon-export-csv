require 'httparty'

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
    response = HTTParty.post("#{@url}:#{@port}/oauth/access_token", body: body)
    debug response

    if response.success?
      Auth.new(response["account_id"].to_s, response["access_token"].to_s)
    else
      raise RuntimeError, "API call failed: #{response["message"]}"
    end
  end

  def domains(account_id, access_token)
    headers  = { "Authorization" => "Bearer #{access_token}" }
    response = HTTParty.get("#{@url}:#{@port}/v2/#{account_id}/domains", headers: headers)
    debug response
    response["data"]
  end

  Auth = Struct.new(:account_id, :access_token)

  private

  def debug(message)
    STDERR.puts '#'*30
    STDERR.puts message
    STDERR.puts '#'*30
  end
end
