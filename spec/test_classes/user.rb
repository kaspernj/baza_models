class User < BazaModels::Model
  attr_accessor :custom_valid

  belongs_to :organization
  has_one :person, dependent: :restrict_with_error

  has_many :roles, dependent: :destroy
  has_many :admin_roles, -> { where(role: "administrator") }, class_name: "Role", dependent: :restrict_with_error

  validates :email, presence: true
  validate :validate_custom_errors

  scope :admin_roles_scope, -> { joins(:roles).where(roles: {role: 'administrator'}) }

  # Used to test callbacks.
  BazaModels::Model::CALLBACK_TYPES.each do |callback_type|
    attr_reader "#{callback_type}_called"
    __send__(callback_type, :set_callback, callback_type)
  end

private

  def set_callback(callback_type)
    variable_name = "@#{callback_type}_called"
    instance_variable_set(variable_name, 0) unless instance_variable_get(variable_name)
    instance_variable_set(variable_name, instance_variable_get(variable_name) + 1)
  end

  def validate_custom_errors
    if custom_valid == false
      errors.add(:base, 'Custom validate failed')
    end
  end
end
