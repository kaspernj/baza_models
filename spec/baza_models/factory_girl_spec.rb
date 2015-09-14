require "spec_helper"

describe "factory girl with baza models" do
  include DatabaseHelper

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }

  it "creates the user" do
    expect(user.email).to eq "user@example.com"
    expect(user.organization).to eq organization
  end
end
