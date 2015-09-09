require "spec_helper"

describe "BazaModels::Model" do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  describe "#email" do
    it "returns set attributes" do
      expect(user.email).to eq "test@example.com"
    end

    it "returns nil for attributes that hasn't been set" do
      user = User.new
      expect(user.email).to eq nil
    end
  end

  it "#id #to_param" do
    expect(user.id).to eq nil
    expect(user.to_param).to eq nil
    user.save!
    expect(user.id).to_not eq nil
    expect(user.to_param).to_not eq nil
  end

  it "#email=" do
    user.email = "newemail@example.com"
    expect(user.email).to eq "newemail@example.com"
  end

  it "#email_was" do
    user.email = "newemail@example.com"
    expect(user.email_was).to eq "test@example.com"
  end

  it "#changes" do
    user.email = "newemail@example.com"
    expect(user.changes).to eq email: "newemail@example.com"
  end

  describe "#save" do
    it "inserts a new record when new" do
      expect(user.new_record?).to eq true
      user.save!
      expect(user.id).to eq 1
      expect(user.new_record?).to eq false
    end
  end

  it "#update_attributes" do
    user.save!
    expect(user.update_attributes(email: "newemail@example.com")).to eq true
    expect(user.email).to eq "newemail@example.com"
  end

  it "#before_save, #after_save" do
    expect(user.before_save_called).to eq nil
    expect(user.after_save_called).to eq nil
    user.save!
    expect(user.before_save_called).to eq 1
    expect(user.after_save_called).to eq 1
    user.save!
    expect(user.before_save_called).to eq 2
    expect(user.after_save_called).to eq 2
  end

  it "#before_create, #after_create" do
    expect(user.before_create_called).to eq nil
    expect(user.after_create_called).to eq nil
    user.save!
    expect(user.before_create_called).to eq 1
    expect(user.after_create_called).to eq 1
    user.save!
    expect(user.before_create_called).to eq 1
    expect(user.after_create_called).to eq 1
  end

  it "#before_destroy, #after_destroy" do
    user.save!
    expect(user.before_destroy_called).to eq nil
    expect(user.after_destroy_called).to eq nil
    user.destroy!
    expect(user.before_destroy_called).to eq 1
    expect(user.after_destroy_called).to eq 1
  end
end
