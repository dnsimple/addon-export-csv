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
      Account.new(account_id, access_token).tap do |account|
        @accounts.store(account)
      end
    end

    def get_account(account_id)
      @accounts.get(account_id) or raise Errors::NotFound, "No account with ID=#{account_id} found"
    end

    def get_account_domains(account_id)
      account = get_account(account_id)
      @api_client.domains(account_id, account.access_token)
    end

    def get_account_domains_as_csv(account_id)
      export_to_csv(get_account_domains(account_id))
    end

    private

    def export_to_csv(domain_data)
      CSV.generate(write_headers: true, headers: [
        "Name",
        "State",
        "Expiration",
        "Whois privacy",
        "Auto renewal"
      ]) do |csv|
        domain_data.each do |domain|
          csv << [
            domain["name"],
            domain["state"],
            domain["expires_on"],
            domain["private_whois"],
            domain["auto_renew"]
          ]
        end
      end
    end

  end
end
