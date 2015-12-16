require 'account'

RSpec.describe CsvExport::Account do

  subject { described_class.new(id, access_token) }
  let(:id) { "id" }
  let(:access_token) { "access_token" }

  it "has an id" do
    expect(subject.id).to eq(id)
  end

  it "has an access token" do
    expect(subject.access_token).to eq(access_token)
  end

end
