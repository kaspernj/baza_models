class User < BazaModels::Model
  attr_accessor :custom_valid, :before_save_block_called, :validate_confirmation, :validate_uniqueness

  belongs_to :organization
  has_one :person, dependent: :restrict_with_error
  has_one :user_passport, dependent: :destroy

  has_many :roles, dependent: :destroy
  has_many :admin_roles, -> { where(role: "administrator") }, class_name: "Role", dependent: :restrict_with_error

  validates :email, presence: true, length: {minimum: 2, maximum: 100}, format: {with: /\A(.+)@(.+)\.(.+)\Z/}
  validate :validate_custom_errors
  validates_uniqueness_of :email, scope: :organization_id, if: :validate_uniqueness
  validates_confirmation_of :email, if: :validate_confirmation

  scope :admin_roles_scope, -> { joins(:roles).where(roles: {role: "administrator"}) }
  scope :created_at_since, ->(date) { where("users.created_at >= ?", date) }

  before_save do
    self.before_save_block_called ||= 0
    self.before_save_block_called += 1
  end

  # Used to test callbacks.
  BazaModels::Model::CALLBACK_TYPES.each do |callback_type|
    attr_reader :"#{callback_type}_called"

    __send__(callback_type, :add_callback, callback_type)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[created_at_since]
  end

private

  def add_callback(callback_type)
    variable_name = "@#{callback_type}_called"
    instance_variable_set(variable_name, 0) unless instance_variable_get(variable_name)
    instance_variable_set(variable_name, instance_variable_get(variable_name) + 1)
  end

  def validate_custom_errors
    errors.add(:base, "Custom validate failed") if custom_valid == false
  end
end
