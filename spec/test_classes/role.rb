class Role < BazaModels::Model
  belongs_to :user

  scope :admin_roles, -> { where(role: 'administrator') }

  validates :role, presence: true
end
