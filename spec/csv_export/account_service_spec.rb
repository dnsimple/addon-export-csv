require 'account_service'

require 'api_client'
require 'account'
require 'account_storage'

RSpec.describe CsvExport::AccountService do
  subject { described_class.new(account_storage, api_client) }
  let(:account_storage) { CsvExport::RedisAccountStorage.new }
  let(:api_client) { double(ApiClient) }

  describe "#authenticate_account" do
    let(:code) { "code" }
    let(:account_id) { "1" }
    let(:access_token) { "access-token" }
    let(:authorization) { ApiClient::Auth.new(account_id, access_token) }

    before do
      allow(api_client).to receive(:authorization).with(code).and_return(authorization)
    end

    context "when no account with that id exists" do
      it "stores the account" do
        subject.authenticate_account(code)

        account = account_storage.get(account_id)
        expect(account.id).to eq(account_id)
        expect(account.access_token).to eq(access_token)
      end
    end

    context "when an account with that id exists" do
      let(:old_account) { CsvExport::Account.new(account_id, "old-access-token") }

      before do
        account_storage.store(old_account)
      end

      it "updates the account" do
        subject.authenticate_account(code)

        updated_account = account_storage.get(account_id)
        expect(updated_account.id).to eq(account_id)
        expect(updated_account.access_token).to eq(access_token)
      end
    end
  end

  describe "#get_account_domains" do
    context "when the account is authenticated" do
      context "when the API credentials are valid" do
        it "returns the domain's data"
      end

      context "when the API credentials are valid" do
        it "returns an error"
      end
    end

    context "when the account is not authenticated" do
      it "returns an error"
    end
  end

end
