class Role < BazaModels::Model
  belongs_to :user

  has_one :organization, through: :user

  scope :admin_roles, -> { where(role: "administrator") }

  validates :role, presence: true

  delegate :email, to: :user
  delegate :created_at, to: :user, prefix: true
end
