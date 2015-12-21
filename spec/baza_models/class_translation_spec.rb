require "spec_helper"

describe BazaModels::ClassTranslation do
  include DatabaseHelper

  it "#model_name" do
    expect(User.model_name.human).to eq "User"
  end

  it "#param_key" do
    expect(User.model_name.param_key).to eq "user"
  end

  it "#route_key" do
    expect(User.model_name.route_key).to eq "users"
  end
end
