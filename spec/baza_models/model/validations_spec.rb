require "spec_helper"

describe BazaModels::Model::Validations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  describe "#valid?" do
    it "returns true when valid" do
      expect(user.valid?).to eq true
    end

    it "returns false when invalid" do
      user.email = " "
      expect(user.valid?).to eq false
    end
  end

  it "#before_validation, #after_validation" do
    expect(user.before_validation_called).to eq nil
    expect(user.after_validation_called).to eq nil
    user.valid?
    expect(user.before_validation_called).to eq 1
    expect(user.after_validation_called).to eq 1
  end

  it "#before_validation_on_create, #after_validation_on_create, #before_validation_on_update, #after_validation_on_update" do
    expect(user.before_validation_on_create_called).to eq nil
    expect(user.after_validation_on_create_called).to eq nil

    expect(user.before_validation_on_update_called).to eq nil
    expect(user.after_validation_on_update_called).to eq nil

    user.save!

    expect(user.before_validation_on_create_called).to eq 1
    expect(user.after_validation_on_create_called).to eq 1

    expect(user.before_validation_on_update_called).to eq nil
    expect(user.after_validation_on_update_called).to eq nil

    user.update_attributes!(email: "newemail@example.com")

    expect(user.before_validation_on_create_called).to eq 1
    expect(user.after_validation_on_create_called).to eq 1

    expect(user.before_validation_on_update_called).to eq 1
    expect(user.after_validation_on_update_called).to eq 1
  end
end
