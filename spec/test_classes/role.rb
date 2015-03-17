class Role < BazaModels::Model
  belongs_to :user

  validates :role, presence: true
end
