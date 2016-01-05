require 'csv_export'

RSpec.describe CsvExport::AccountService do
  subject { described_class.new(account_storage, api_client) }
  let(:account_storage) { CsvExport::RedisAccountStorage.new }
  let(:api_client) { double(ApiClient) }

  let(:account_id) { "1" }
  let(:access_token) { "access-token" }

  before do
    Redis.current.flushall
  end

  describe "#authenticate_account" do
    let(:code) { "code" }
    let(:authorization) { ApiClient::Auth.new(account_id, access_token) }

    before do
      allow(api_client).to receive(:authorization).with(code).and_return(authorization)
    end

    context "when no account with that id exists" do
      it "stores and returns the account" do
        account = subject.authenticate_account(code)

        expect(account.id).to eq(account_id)
        expect(account.access_token).to eq(access_token)
        expect(account_storage.get(account_id)).not_to be_nil
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


  describe "#get_account" do
    context "when an account with given id exits" do
      before do
        subject.create_account(account_id, access_token)
      end

      it "returns the account" do
        account = subject.get_account(account_id)

        expect(account.id).to eq(account_id)
        expect(account.access_token).to eq(access_token)
      end
    end

    context "when no account with given id exits" do
      it "returns an error" do
        expect{
          subject.get_account(account_id)
        }.to raise_error(CsvExport::Errors::NotFound)
      end
    end
  end


  describe "#get_account_domains" do
    context "when the account is authenticated" do
      before do
        subject.create_account(account_id, access_token)
      end

      context "when the API credentials are valid" do
        let(:domain_data) { [] }

        it "returns the domain's data" do
          allow(api_client).to receive(:domains).with(account_id, access_token).and_return(domain_data)

          result = subject.get_account_domains(account_id)

          expect(result).to eq(domain_data)
        end
      end

      context "when the API credentials are not valid" do
        it "returns an error"
      end
    end

    context "when the account is not authenticated" do
      it "returns an error" do
        expect {
          subject.get_account_domains(account_id)
        }.to raise_error(CsvExport::Errors::NotFound)
      end
    end
  end


  describe "#get_account_domains_as_csv" do
    context "when the account is authenticated" do
      before do
        subject.create_account(account_id, access_token)
      end

      context "when the API credentials are valid" do
        let(:domain_data) do
          [
            {
              "name" => "example.com",
              "state" => "registered",
              "expires_on" => "2017-12-19",
              "private_whois" => "true",
              "auto_renew" => "false"
            }
          ]
        end

        it "returns the domain's data" do
          allow(api_client).to receive(:domains).with(account_id, access_token).and_return(domain_data)

          result = subject.get_account_domains_as_csv(account_id)

          expect(result).to eq("Name,State,Expiration,Whois privacy,Auto renewal\nexample.com,registered,2017-12-19,true,false\n")
        end
      end

      context "when the API credentials are not valid" do
        it "returns an error"
      end
    end

    context "when the account is not authenticated" do
      it "returns an error" do
        expect {
          subject.get_account_domains_as_csv(account_id)
        }.to raise_error(CsvExport::Errors::NotFound)
      end
    end
  end

end
