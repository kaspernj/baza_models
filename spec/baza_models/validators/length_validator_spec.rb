require "spec_helper"

describe BazaModels::Validators::LengthValidator do
  include DatabaseHelper

  it "validates minimum length" do
    user = User.new(email: "a")

    expect(user.valid?).to be false
    expect(user.errors.full_messages).to include "Email is too short"
  end

  it "validates maximum length" do
    user = User.new(email: "a" * 101)

    expect(user.valid?).to be false
    expect(user.errors.full_messages).to include "Email is too long"
  end
end
