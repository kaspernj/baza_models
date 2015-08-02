module DatabaseHelper
  def self.included(base)
    base.instance_eval do
      let(:db) { @db }

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
    end
  end
end
