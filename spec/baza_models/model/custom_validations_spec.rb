require "spec_helper"

describe BazaModels::Model::CustomValidations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }

  it "validates custom validations" do
    user.custom_valid = false
    expect(user.valid?).to be false
    expect(user.errors.full_messages.join(". ")).to eq "Custom validate failed"
    expect(user.save).to be false

    user.custom_valid = nil
    expect(user.valid?).to be true
    expect(user.save).to be true
  end
end
