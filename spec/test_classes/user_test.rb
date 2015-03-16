class UserTest < BazaModels::Model
  validates :email, presence: true
end
