require "spec_helper"

describe BazaModels::Model::CustomValidations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }

  it "validates custom validations" do
    user.custom_valid = false
    expect(user.valid?).to eq false
    expect(user.errors.full_messages.join(". ")).to eq "Custom validate failed"
    expect(user.save).to eq false

    user.custom_valid = nil
    expect(user.valid?).to eq true
    expect(user.save).to eq true
  end
end
