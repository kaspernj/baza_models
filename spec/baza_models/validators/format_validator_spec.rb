require "spec_helper"

describe BazaModels::Validators::FormatValidator do
  include DatabaseHelper

  it "detects invalid formats" do
    user = User.new(email: "invalid")

    expect(user.valid?).to be false
    expect(user.errors.full_messages).to eq ["Email has an invalid format"]
  end

  it "allows correct formats" do
    user = User.new(email: "valid@example.com")
    expect(user.valid?).to be true
  end
end
