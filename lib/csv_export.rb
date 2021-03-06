require_relative 'csv_export/errors'
require_relative 'csv_export/account'
require_relative 'csv_export/account_service'
require_relative 'csv_export/account_storage'

require_relative 'api_client'


module CsvExport

  def self.account_service
    @account_service ||= AccountService.new(account_storage, api_client)
  end

  def self.account_storage
    @accounts_storage ||= RedisAccountStorage.new
  end

  def self.api_client
    @api_client ||= ApiClient.new(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"])
  end

end
