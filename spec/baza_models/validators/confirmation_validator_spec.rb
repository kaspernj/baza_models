require "spec_helper"

describe BazaModels::Validators::ConfirmationValidator do
  include DatabaseHelper

  it "detects no confirmation" do
    user = User.new(email: "invalid@example.com")
    user.validate_confirmation = true

    expect(user.valid?).to eq false
    expect(user.errors.full_messages).to eq ["Email hasn't been confirmed"]
  end

  it "detects invalid confirmations" do
    user = User.new(email: "valid@example.com", email_confirmation: "unvaid@example.com")
    user.validate_confirmation = true

    expect(user.valid?).to eq false
    expect(user.errors.full_messages).to eq ["Email was not the same as the confirmation"]
  end

  it "allows correct confirmations" do
    user = User.new(email: "valid@example.com", email_confirmation: "valid@example.com")
    user.validate_confirmation = true

    expect(user.valid?).to eq true
  end
end
