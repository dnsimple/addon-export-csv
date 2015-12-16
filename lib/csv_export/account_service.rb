module CsvExport
  class AccountService

    def initialize(account_storage, api_client)
      @accounts = account_storage
      @api_client = api_client
    end

    def authenticate_account(code)
      auth = @api_client.authorization(code)
      @accounts.store(Account.new(auth.account_id, auth.access_token))
    end

  end
end
