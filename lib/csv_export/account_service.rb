module CsvExport
  class AccountService

    def initialize(account_storage, api_client)
      @accounts = account_storage
      @api_client = api_client
    end

    def authenticate_account(code)
      auth = @api_client.authorization(code)
      create_account(auth.account_id, auth.access_token)
    end

    def create_account(account_id, access_token)
      account = Account.new(account_id, access_token)
      @accounts.store(account)
    end

    def get_account(account_id)
      @accounts.get(account_id) or raise Errors::NotFound, "No account with ID=#{account_id} found"
    end

    def get_account_domains(account_id)
      account = get_account(account_id)
      @api_client.domains(account_id, account.access_token)
    end

  end
end
