class Account
  attr_reader :id, :access_token

  def initialize(id, access_token)
    @id = id
    @access_token = access_token
  end
end
