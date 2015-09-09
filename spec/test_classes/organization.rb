class Organization < BazaModels::Model
  has_many :users, dependent: :destroy
end
