class User < BazaModels::Model
  has_many :roles
  has_many :admin_roles, -> { where(role: "administrator") }, class_name: "Role"

  validates :email, presence: true

  scope :admin_roles, -> { joins(:roles).where(roles: {role: 'administrator'}) }

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
end
