# Rectify

[![Code Climate](https://codeclimate.com/github/andypike/rectify/badges/gpa.svg)](https://codeclimate.com/github/andypike/rectify)

Rectify is a gem that provides some lightweight classes that will make it easier
to build Rails applications in a more maintainable way. It's built on top of
several other gems and adds improved APIs to make things easier.

Rectify is an extraction from a number of projects that I've worked on and used
these techniques.

To install, add it to your `Gemfile`:

```
gem "rectify"
```

Then use Bundler to install it:

```
bundle install
```

## Overview

Currently, Rectify consists of two main concepts: Form Objects and Commands. You
can use these separately or together to improve the structure of your Rails
applications.

The main problem that Rectify tries to solve is where your logic should go. Commonly,
business logic is either placed in the controller or the model. The opinion of Rectify
is that both of these places are incorrect and that your models in particular are
doing too much.

Rectify's opinion is that controllers should just be concerned with HTTP related
things and models should just be concerned with data access. The problem then
becomes, how and where do you place validations and other business logic.

Using Rectify, the Form Objects contain validations and represent the data input
of your system. Commands then take a Form Object (as well as other data) and
perform a single action which is invoked by a controller.

Here's an example when a user registers an account. This creates a user, sends
some emails, does some special auditing and integrates with a third party system:

```ruby
class UserController < ApplicationController
  def new
    @form = RegistrationForm.new
  end

  def create
    @form = RegistrationForm.from_params(params)

    RegisterAccount.call(@form) do
      on(:ok)      { redirect_to dashboard_path }
      on(:invalid) { render :new }
      on(:already_registered) { redirect_to login_path }
    end
  end
end
```

The `RegistrationForm` Form Object encapsulates the relevant data that is required for the
action and the `RegisterAccount` Command encapsulates the business logic of registering
a new account. The controller is clean and business logic now has a natural home:

```
HTTP           => Controller  (redirecting, rendering, etc)
Data Input     => Form Object (validation, acceptable input)
Business Logic => Command     (logic for a specific use case)
Data Access    => Model       (relationships, queries)
```

The next sections will give further details about using Form Objects and Commands.

## Form Objects

Form objects in Rectify are based on [Virtus](https://github.com/solnic/virtus)
and make them compatible with Rails form builders, add ActiveModel validations
and all allow you to specify a model to mimic.

Here is how you define a form object:

```ruby
class UserForm < Rectify::Form
  attribute :first_name,  String
  attribute :last_name,   String

  validates :first_name, :last_name, :presence => true
end
```

You can then set that up in your controller instead of a normal ActiveRecord model:

```ruby
class UsersController < ApplicationController
  def new
    @form = UserForm.new
  end

  def create
    @form = UserForm.from_params(params)

    if @form.valid?
      # Do something interesting
    end
  end
end
```

You can use the form object with form builders such as
[simple_form](https://github.com/plataformatec/simple_form) like this:

```ruby
= simple_form_for @form do |f|
  = f.input :first_name
  = f.input :last_name
  = f.submit
```

### Mimicking models

When the form is generated it uses the name of the form class to infer what "model"
it should mimic. In the example above, it will mimic the `User` model as it removes
the `Form` suffix from the form class name by default.

The model being mimicked affects two things about the form:

1. The route path helpers to use as the url to post to, for example: `users_path`.
2. The parent key in the params hash that the controller receives, for example
`user` in this case:

```ruby
params = {
  "id" => "1",
  "user" => {
    "first_name" => "Andy",
    "last_name"  => "Pike"
  }
}
```

You might want to mimic something different and use a form object that is not
named in a way where the correct model can be mimicked. For example:

```ruby
class UserForm < Rectify::Form
  mimic :teacher

  attribute :first_name,  String
  attribute :last_name,   String

  validates :first_name, :last_name, :presence => true
end
```

In this example we are using the same `UserForm` class but am mimicking a
`Teacher` model. The above form will then use the route path helpers
`teachers_path` and the params key will be `teacher` rather than `users_path`
and `user` respectively.

### Attributes

You define your attributes for your form object just like you do in
[Virtus](https://github.com/solnic/virtus).

By default, Rectify forms include an `id` attribute for you so you don't need to
add that. We use this `id` attribute to fulfil some of the requirements of ActiveModel
so your forms will work with form builders. For example, your form object has a
`#persisted?` method. Your form object is never persisted so technically this
should always return `false`.

However, you are normally representing something that is persistable. So we use
the value of `id` to workout if what this should return. If `id` is a number
greater than zero then we assume it is persisted otherwise we assume it isn't. This
is important as it affects where your form is posted (to the `#create` or
`#update` action in your controller).

#### Populating attributes

There are a number of ways to populate attributes of a form object.

**Constructor**

You can use the constructor and pass it a hash of values:

```ruby
form = UserForm.new(:first_name => "Andy", :last_name => "Pike")
```

**Prams hash**

You can use the params hash that a Rails controller provides that contains all
the data in the request:

```ruby
form = UserForm.from_params(params)
```

When populating from params we will populate the built in `id` attribute from the
root of the params hash and populate the rest of the form attributes from within
the parent key. For example:

```ruby
params = {
  "id" => "1",
  "user" => {
    "first_name" => "Andy",
    "last_name"  => "Pike"
  }
}

form = UserForm.from_params(params)

form.id         # => 1
form.first_name # => "Andy"
form.last_name  # => "Pike"
```

The other thing to notice is that (thanks to Virtus), attribute values are cast
to the correct type. The params hash is actually all string based but when you
get values from the form, they are returned as the correct type (see `id` above).

**Model**

The final way is to pass an ActiveModel to the form to populate it's attribute
values. This is useful when editing a model:

```ruby
user = User.create(:first_name => "Andy", :last_name => "Pike")

form = UserForm.from_model(user)

form.id         # => 1
form.first_name # => "Andy"
form.last_name  # => "Pike"
```

One important thing that is different about Rectify forms is that they are not
bound by a model. You can use a model to populate the forms attributes but that
is all it will do. It does not keep a reference to the model or interact with it.
Rectify forms are designed to be lightweight representations of the data you want
to collect or show in your forms, not something that is linked to a model. This
allows you to create any form that you like which doesn't need to match the
representation of the data in the database.

### Validations

Rectify includes `ActiveModel::Validations` for you so you can use all of the
Rails validations that you are used to within your models.

Your Form Object has a `#valid?` method that will validate the attributes of your
form as well as any nested form objects.

### Strong Parameters

Did you notice in the example above that there was no mention of strong
parameters. That's because with Form Objects you do not need strong parameters.
You only specify attributes in your form that are allowed to be accepted. All
other data in your params hash is ignored.

## Commands

Docs coming soon...
