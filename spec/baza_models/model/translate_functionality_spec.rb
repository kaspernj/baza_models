require "spec_helper"

describe BazaModels::Model::TranslationFunctionality do
  include DatabaseHelper

  it "#model_name" do
    expect(User.model_name.human).to eq "User"
  end

  it "#human_attribute_name" do
    expect(User.human_attribute_name(:email)).to eq "Email"
  end
end
