require "spec_helper"

describe "BazaModels::Model" do
  let(:db) {
    path = Tempfile.new("baza_test").path
    File.unlink(path) if File.exists?(path)

    db = Baza::Db.new(type: :sqlite3, path: path)
    BazaModels.primary_db = db

    db.tables.create(:user_tests, {
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :email, type: :varchar}
      ],
      indexes: [
        :email
      ]
    })

    db
  }
  let(:user) { UserTest.new(email: "test@example.com") }

  before do
    require "tempfile"
    require "baza"
    require "sqlite3"

    db

    require "test_classes/user_test"
  end

  it "#email" do
    user.email.should eq "test@example.com"
  end

  it "#email=" do
    user.email = "newemail@example.com"
    user.email.should eq "newemail@example.com"
  end

  describe "#valid?" do
    it "returns true when valid" do
      user.valid?.should eq true
    end

    it "returns false when invalid" do
      user.email = " "
      user.valid?.should eq false
    end
  end
end
