[![Build Status](https://api.shippable.com/projects/5506810c5ab6cc13529b84bf/badge?branchName=master)](https://app.shippable.com/projects/5506810c5ab6cc13529b84bf/builds/latest)
[![Code Climate](https://codeclimate.com/github/kaspernj/baza_models/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/baza_models)
[![Test Coverage](https://codeclimate.com/github/kaspernj/baza_models/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/baza_models)

# BazaModels

An attempt to recreate 90% of the ActiveRecord functionality in a very simple way.

The examples in this readme actually work.

## Relationships

### has_many
```ruby
class User < BazaModels::Model
  has_many :roles
  has_many :admin_roles, -> { where(role: "administrator") }, class_name: "Role", dependent: :restrict_with_error # :destroy-dependent also works
end
```

### has_one
```ruby
class User < BazaModels::Model
  has_one :person, dependent: :restrict_with_error # :destroy-dependent also works
end
```

### belongs_to
```ruby
class Role < BazaModels::Model
  belongs_to :user
end
```

## Validations

### Presence
```ruby
class User < BazaModels::Model
  validates :email, presence: true
end
```

## Queries

### Where
```ruby
users = User.where(email: "myemail@example.com").to_a
```

### Group
```ruby
users = User.group(:email).to_a
```

### Order
```ruby
ùsers = User.order(:email).to_a
``

### Includes / autoloading / eager loading
```ruby
users = User.includes(:roles)
```

### Joins
```ruby
users = User.joins(:roles).where(roles: {role: 'administrator'})
```

### Other methods...
```ruby
User.where(email: "myemail@example.com").to_sql #=> "SELECT `users`.* FROM..."
User.any? #=> true
User.all #=> BazaModels::Query<...>
User.select(:email)
User.limit(5)
User.to_enum
User.first
User.last
User.order(:id).reverse_order
```


## Setting and saving attributes

### Setting
```ruby
role.assign_attributes(user: user, role: "administrator")
role.save! #=> true || raising error

role.update_attributes!(user: user, role: "administrator") #=> true || raising error
role.role = "administrator"
role.save #=> true || false
```

### Getting
```ruby
role.role #=> "administrator"
role.user #=> [some user]
role.has_attribute?(:created_at) #=> true
```

## Contributing to baza_models

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 kaspernj. See LICENSE.txt for
further details.

