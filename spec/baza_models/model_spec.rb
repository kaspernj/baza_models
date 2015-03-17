require "spec_helper"

describe "BazaModels::Model" do
  let(:db) { @db }
  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  before do
    @count ||= 0
    @count += 1

    require "tempfile"
    require "baza"
    require "sqlite3"

    path = Tempfile.new("baza_test").path
    File.unlink(path) if File.exists?(path)

    @db = Baza::Db.new(type: :sqlite3, path: path, debug: false)
    BazaModels.primary_db = @db

    @db.tables.create(:users, {
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :email, type: :varchar}
      ],
      indexes: [
        :email
      ]
    })

    @db.tables.create(:roles, {
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :user_id, type: :int},
        {name: :role, type: :varchar}
      ],
      indexes: [
        :user_id
      ]
    })

    require "test_classes/user"
    require "test_classes/role"
  end

  after do
    BazaModels.primary_db = nil

    @db.close
    path = db.args[:path]
    File.unlink(path)
    Thread.current[:baza] = nil
    @db = nil
  end

  it "#email" do
    user.email.should eq "test@example.com"
  end

  it "#email=" do
    user.email = "newemail@example.com"
    user.email.should eq "newemail@example.com"
  end

  it "#email_was" do
    user.email = "newemail@example.com"
    user.email_was.should eq "test@example.com"
  end

  it "#changes" do
    user.email = "newemail@example.com"
    user.changes.should eq(email: "newemail@example.com")
  end

  describe "#save" do
    it "inserts a new record when new" do
      user.new_record?.should eq true
      user.save
      user.id.should eq 1
      user.new_record?.should eq false
    end
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

  it "#update_attributes" do
    user.save!
    user.update_attributes(email: "newemail@example.com").should eq true
    user.email.should eq "newemail@example.com"
    user.update_attributes(email: " ").should eq false
  end

  it "#before_save, #after_save" do
    user.before_save_called.should eq nil
    user.after_save_called.should eq nil
    user.save!
    user.before_save_called.should eq 1
    user.after_save_called.should eq 1
    user.save!
    user.before_save_called.should eq 2
    user.after_save_called.should eq 2
  end

  it "#before_create, #after_create" do
    user.before_create_called.should eq nil
    user.after_create_called.should eq nil
    user.save!
    user.before_create_called.should eq 1
    user.after_create_called.should eq 1
    user.save!
    user.before_create_called.should eq 1
    user.after_create_called.should eq 1
  end

  it "#before_destroy, #after_destroy" do
    user.save!
    user.before_destroy_called.should eq nil
    user.after_destroy_called.should eq nil
    user.destroy!
    user.before_destroy_called.should eq 1
    user.after_destroy_called.should eq 1
  end

  it "#before_validation, #after_validation" do
    user.before_validation_called.should eq nil
    user.after_validation_called.should eq nil
    user.valid?
    user.before_validation_called.should eq 1
    user.after_validation_called.should eq 1
  end

  it "#before_validation_on_create, #after_validation_on_create, #before_validation_on_update, #after_validation_on_update" do
    user.before_validation_on_create_called.should eq nil
    user.after_validation_on_create_called.should eq nil

    user.before_validation_on_update_called.should eq nil
    user.after_validation_on_update_called.should eq nil

    user.save!

    user.before_validation_on_create_called.should eq 1
    user.after_validation_on_create_called.should eq 1

    user.before_validation_on_update_called.should eq nil
    user.after_validation_on_update_called.should eq nil

    user.update_attributes!(email: "newemail@example.com")

    user.before_validation_on_create_called.should eq 1
    user.after_validation_on_create_called.should eq 1

    user.before_validation_on_update_called.should eq 1
    user.after_validation_on_update_called.should eq 1
  end

  it "#find" do
    user.save!
    user_found = User.find(user.id)
    user_found.email.should eq "test@example.com"
  end

  it "#find_by" do
    user.save!
    user_found = User.find_by(id: 1, email: "test@example.com")
    user_found.email.should eq "test@example.com"
  end

  it "#where" do
    user.save!
    query = User.where(email: "test@example.com")
    query.to_sql.should eq "SELECT * FROM `users` WHERE `users`.`email` = 'test@example.com'"
    query.to_a.should eq [user]
  end

  context "relationships" do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    it "#belongs_to" do
      role_user.user.should eq user
    end

    describe "#has_many" do
      it "returns whole collections without arguments" do
        user.roles.to_a.should eq [role_user, role_admin]
      end

      it "supports class_name and proc-arguments" do
        user.admin_roles.to_a.should eq [role_admin]
      end
    end
  end
end