# Rectify

[![Code Climate](https://codeclimate.com/github/andypike/rectify/badges/gpa.svg)](https://codeclimate.com/github/andypike/rectify)
[![Build Status](https://travis-ci.org/andypike/rectify.svg?branch=master)](https://travis-ci.org/andypike/rectify)
[![Gem Version](https://badge.fury.io/rb/rectify.svg)](https://badge.fury.io/rb/rectify)

Rectify is a gem that provides some lightweight classes that will make it easier
to build Rails applications in a more maintainable way. It's built on top of
several other gems and adds improved APIs to make things easier.

Rectify is an extraction from a number of projects that use these techniques and
proved to be successful.

## Video

In June 2016, I spoke at RubyC about Rectify and how it can be used to improve
areas of your application. The full video and slides can be found here:

[Building maintainable Rails apps - RubyC 2016](http://andypike.com/blog/conferences/rubyc-2016/)

## Installation

To install, add it to your `Gemfile`:

```ruby
gem "rectify"
```

Then use Bundler to install it:

```
bundle install
```

## Overview

Currently, Rectify consists of the following concepts:

* [Form Objects](#form-objects)
* [Commands](#commands)
* [Presenters](#presenters)
* [Query Objects](#query-objects)

You can use these separately or together to improve the structure of your Rails
applications.

The main problem that Rectify tries to solve is where your logic should go.
Commonly, business logic is either placed in the controller or the model and the
views are filled with too much logic. The opinion of Rectify is that these
places are incorrect and that your models in particular are doing too much.

Rectify's opinion is that controllers should just be concerned with HTTP related
things and models should just be concerned with data relationships. The problem
then becomes, how and where do you place validations, queries and other business
logic?

Using Rectify, Form Objects contain validations and represent the data input
of your system. Commands then take a Form Object (as well as other data) and
perform a single action which is invoked by a controller. Query objects
encapsulate a single database query (and any logic it needs). Presenters contain
the presentation logic in a way that is easily testable and keeps your views as
clean as possible.

Rectify is designed to be very lightweight and allows you to use some or all of
it's components. We also advise to use these components where they make sense
not just blindly everywhere. More on that later.

Here's an example controller that shows details about a user and also allows a
user to register an account. This creates a user, sends some emails, does some
special auditing and integrates with a third party system:

```ruby
class UserController < ApplicationController
  include Rectify::ControllerHelpers

  def show
    present UserDetailsPresenter.new(:user => current_user)
  end

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

The `RegistrationForm` Form Object encapsulates the relevant data that is
required for the action and the `RegisterAccount` Command encapsulates the
business logic of registering a new account. The controller is clean and
business logic now has a natural home:

```
HTTP             => Controller   (redirecting, rendering, etc)
Data Input       => Form Object  (validation, acceptable input)
Business Logic   => Command      (logic for a specific use case)
Data Persistence => Model        (relationships between models)
Data Access      => Query Object (database queries)
View Logic       => Presenter    (formatting data)
```

The next sections will give further details about using Form Objects, Commands
and Presenters.

## Form Objects

The role of the Form Object is to manage the input data for a given action. It
validates data and only allows whitelisted attributes (replacing the need for
Strong Parameters). This is a departure from "The Rails Way" where the model
contains the validations. Form Objects help to reduce the weight of your models
for one, but also, in an app of reasonable complexity even simple things like
validations become harder because context is important.

For example, you can add validation for a `User` model but there are different
context where the validations change. When a user registers themselves you might
have one set of validations, when an admin edits that user you might have
another set, maybe even when a user edits themselves you may have a third. In
"The Rails Way" you would have to have conditional validation in your model.
With Rectify you can have a different Form Object per context and keep things
easier to manage.

Form objects in Rectify are based on [Virtus](https://github.com/solnic/virtus)
and make them compatible with Rails form builders, add ActiveModel validations
and all allow you to specify a model to mimic.

Here is how you define a form object:

```ruby
class UserForm < Rectify::Form
  attribute :first_name, String
  attribute :last_name,  String

  validates :first_name, :last_name, :presence => true
end
```

You can then set that up in your controller instead of a normal ActiveRecord
model:

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

When the form is generated it uses the name of the form class to infer what
"model" it should mimic. In the example above, it will mimic the `User` model
as it removes the `Form` suffix from the form class name by default.

The model being mimicked affects two things about the form:

1. The route path helpers to use as the url to post to, for example:
`users_path`.
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
add that. We use this `id` attribute to fulfill some of the requirements of
ActiveModel so your forms will work with form builders. For example, your form
object has a `#persisted?` method. Your form object is never persisted so
technically this should always return `false`.

However, you are normally representing something that is persistable. So we use
the value of `id` to workout if what this should return. If `id` is a number
greater than zero then we assume it is persisted otherwise we assume it isn't.
This is important as it affects where your form is posted (to the `#create` or
`#update` action in your controller).

#### Populating attributes

There are a number of ways to populate attributes of a form object.

**Constructor**

You can use the constructor and pass it a hash of values:

```ruby
form = UserForm.new(:first_name => "Andy", :last_name => "Pike")
```

**Params hash**

You can use the params hash that a Rails controller provides that contains all
the data in the request:

```ruby
form = UserForm.from_params(params)
```

When populating from params we will populate the built in `id` attribute from
the root of the params hash and populate the rest of the form attributes from
within the parent key. For example:

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
get values from the form, they are returned as the correct type (see `id`
above).

In addition to the params hash, you may want to add additional contextual data.
This can be done by supplying a second hash to the `.from_params` method.
Elements from this hash will be available to populate form attributes as if they
were under the params key:

```ruby
form = UserForm.from_params(params, :ip_address => "1.2.3.4")

form.id         # => 1
form.first_name # => "Andy"
form.last_name  # => "Pike"
form.ip_address # => "1.2.3.4"
```

**Model**

You can pass a Ruby object instance (which is normally an ActiveModel
but can be any PORO) to the form to populate it's attribute values. This is useful
when editing a model:

```ruby
user = User.create(:first_name => "Andy", :last_name => "Pike")

form = UserForm.from_model(user)

form.id         # => 1
form.first_name # => "Andy"
form.last_name  # => "Pike"
```

This works by trying to match (deeply) the attributes of the form object with the
passed in object. If there is matching attribute or method in the model, then
whatever it returns will be assigned to the form attribute.

This works great for most cases, but sometimes you need more control and need the
ability to do custom mapping from the model to the form. When this is required,
you just need to implement the `#map_model` method in your form object:

```ruby
class UserForm < Rectify::Form
  attribute :full_name, String

  def map_model(model)
    self.full_name = "#{model.first_name} #{model.last_name}"
  end
end
```

The `#map_model` method is called as part of `.from_model` after all the automatic
attribute assignment is complete.

One important thing that is different about Rectify forms is that they are not
bound to a model. You can use a model to populate the form's attributes but that
is all it will do. It does not keep a reference to the model or interact with
it.

Rectify forms are designed to be lightweight representations of the data you
want to collect or show in your forms, not something that is linked to a model.
This allows you to create any form that you like which doesn't need to match the
representation of the data in the database.

**JSON**

You can also populate a form object from a JSON string. Just pass it in to the
`.from_json` class method and the form will be created with the attributes
populated by matching names:

```ruby
json = <<-JSON
  {
    "first_name": "Andy",
    "age": 38
  }
JSON

form = UserForm.from_json(json)

form.first_name # => "Andy"
form.age        # => 38
```

Populating the form from JSON can be useful when dealing with API requests into
your system. Which allows you to easily access data and perform validation if
required.

### Validations

Rectify includes `ActiveModel::Validations` for you so you can use all of the
Rails validations that you are used to within your models.

Your Form Object has a `#valid?` method that will validate the attributes of
your form as well as any (deeply) nested form objects and array attributes that
contain form objects. There is also an `#invalid?` method that returns the
opposite of `#valid?`.

The `#valid?` and `#invalid?` methods also take a set of options. These options allow
you to not validate nested form objects or array attributes that contain form objects.
For example:

```ruby
class UserForm < Rectify::Form
  attribute :name,     String
  attribute :address,  AddressForm
  attribute :contacts, Array[ContactForm]

  validates :name, :presence => true
end

class AddressForm < Rectify::Form
  attribute :street,    String
  attribute :town,      String
  attribute :city,      String
  attribute :post_code, String

  validates :street, :post_code, :presence => true
end

class ContactForm < Rectify::Form
  attribute :name,   String
  attribute :number, String

  validates :name, :presence => true
end

form = UserForm.from_params(params)

form.valid?(:exclude_nested => true, :exclude_arrays => true)
```

In this case, the `UserForm` attributes will be validated (`name` in the example above)
but the `address` and `contacts` will not be validated.

### Deep Context

It's sometimes useful to have some context within your form objects when performing
validations or some other type of data manipulation of the input. For example, you
might want to check that the current user owns a particular resource as part of your
validations. You could add the current user as an additional contextual option as
the example shows above. However, sometimes you need this context to be available
at all levels within your form not just at the root form object. You might have nested
forms or arrays of form objects and they all might need access to this context. As
there is no link up the chain from child to parent forms, we need a way to supply
some context and make it available to all child forms.

You can do that using the `#with_context` method.

```ruby
form = UserForm.from_params(params).with_context(:user => current_user)
```

This allows us to access `#context` in any form, and use the information within
it when we perform validations or other work:

```ruby
class PostForm < Rectify::Form
  attribute :blog_id, Integer
  attribute :title,   String
  attribute :body,    String
  attribute :tags,    Array[TagForm]

  validate :check_blog_ownership

  def check_blog_ownership
    return if context.user.blogs.exists?(:id => blog_id)

    errors.add(:blog_id, "not owned by this user")
  end
end

class TagForm < Rectify::Form
  attribute :name,        String
  attribute :category_id, Integer

  validate :check_category

  def check_category
    return if context.user.categories.exists?(:id => category_id)

    errors.add(:category_id, "not a category for this user")
  end
end
```

The context is passed to all nested forms within a form object to make it easy
to perform all the validations and data conversions you might need from within
the form object without having to do this as part of the command.

### Strong Parameters

Did you notice in the example above that there was no mention of Strong
Parameters. That's because with Form Objects you do not need strong parameters.
You only specify attributes in your form that are allowed to be accepted. All
other data in your params hash is ignored.

Take a look at [Virtus](https://github.com/solnic/virtus) for more information
about how to build a form object.

### I18n

Regarding internationalization, the main affected classes when coercing are `Date` and `Time` classes. This is coercing Strings into `Date`, `DateTime` and `Time`. Texts don't usually need to be coerced as they are simple String attributes with nothing special in them.

When coercing dates and times in a multi-language application, each locale will have its own date and time formats, and these formats should be taken into account when coercing strings (inputs entered by the user, or comming form external sources).

So for `Date`, `DateTime` and `Time` classes, Rectify does not support I18n by default. But there are some ways to achieve it indirectly.

Probably the best is to define custom `Virtus::Attribute`s for each kind of temporal class. For exmaple:

```ruby
class LocalizedDate < Virtus::Attribute
  def coerce(value)
    return value unless value.is_a?(String)
    Date.strptime(value, I18n.t("date.formats.short"))
  rescue ArgumentError
    nil
  end
end
```

## Commands

Commands (also known as Service Objects) are the home of your business logic.
They allow you to simplify your models and controllers and allow them to focus
on what they are responsible for. A Command should encapsulate a single user
task such as registering for a new account or placing an order. You of course
don't need to put all code for this task within the Command, you can (and
should) create other classes that your Command uses to perform it's work.

With regard to naming, Rectify suggests using verbs rather than nouns for
Command class names, for example `RegisterAccount`, `PlaceOrder` or
`GenerateEndOfYearReport`. Notice that we don't suffix commands with `Command`
or `Service` or similar.

Commands in Rectify are based on [Wisper](https://github.com/krisleech/wisper)
which allows classes to broadcast events for publish/subscribe capabilities.
`Rectify::Command` is a lightweight class that gives an alternate API and adds
some helper methods to improve Command logic.

The reason for using the pub/sub model rather than returning a result means that
we can reduce the number of conditionals in our code as the outcome of a Command
might be more complex than just success or failure.

Here is an example Command with the structure Rectify suggests (as seen in the
overview above):

```ruby
class RegisterAccount < Rectify::Command
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if form.invalid?

    transaction do
      create_user
      notify_admins
      audit_event
      send_user_details_to_crm
    end

    broadcast(:ok)
  end

  private

  attr_reader :form

  def create_user
    # ...
  end

  def notify_admins
    # ...
  end

  def audit_event
    # ...
  end

  def send_user_details_to_crm
    # ...
  end
end
```

To invoke this Command, you would do the following:

```ruby
def create
  @form = RegistrationForm.from_params(params)

  RegisterAccount.call(@form) do
    on(:ok)      { redirect_to dashboard_path }
    on(:invalid) { render :new }
    on(:already_registered) { redirect_to login_path }
  end
end
```

### What happens inside a Command?

When you call the `.call` class method, Rectify will instantiate a new instance
of the command and will pass the parameters to it's constructor, it will then
call the instance method `#call` on the newly created command object. The
`.call` method also allows you to supply a block where you can handle the events
that may have been broadcast from the command.

The events that your Command broadcasts can be anything, Rectify suggests `:ok`
for success and `:invalid` if the form data is not valid, but it's totally up to
you.

From here you can choose to implement your Command how you see fit. A
`Rectify::Command` only has to have the instance method `#call`.

### Writing Commands

As your application grows and Commands get more complex we recommend using the
structure above. Within the `#call` method you first check that the input data
is valid. If it is you then perform the various tasks that need to be completed.
We recommend using private methods for each step that are well named which makes
it very easy for anyone reading the code to workout what it does.

Feel free to use other classes and objects where appropriate to keep your code
well organized and maintainable.

### Events

Just as in [Wisper](https://github.com/krisleech/wisper), you fire events using
the `broadcast` method. You can use any event name you like. You can also pass
parameters to the handling block:

```ruby
# within the command:

class RegisterAccount < Rectify::Command
  def call
    # ...
    broadcast(:ok, user)
  end
end

# within the controller:

def create
  RegisterAccount.call(@form) do
    on(:ok) { |user| logger.info("#{user.first_name} created") }
  end
end
```

When an event is handled, the appropriate block is called in the context of the
controller. Basically, any method call within the block is delegated back to the
controller.

As well as capturing events in a block, the command will also return a hash of the
broadcast events together with any parameters that were passed. For example:

```ruby
events = RegisterAccount.call(form)

events  # => { :ok => user }
```

There will be a key for each event broadcast and its value will be the parameters
passed. If there is a single parameter it will be the value. If there are no
parameters or many, the hash value for the event key will be an array of the parameters:

```ruby
events = RegisterAccount.call(form)

events  # => {
        #      :ok       => user,
        #      :messages => ["User registered", "Email sent", "Account ready"],
        #      :next     => []
        #    }
```

You may occasionally want to expose a value within a handler block to the view.
You do this via the `expose` method within the handler block. If you want to
use `expose` then you must include the `Rectify::ControllerHelpers` module in
your controller. You pass a hash of the variables you wish to expose to the view
and they will then be available. If you have set a Presenter for the view then
`expose` will try to set an attribute on that presenter. If there is no
Presenter or the Presenter doesn't have a matching attribute then `expose` will
set an instance variable of the same name. See below for more details about
Presenters.

```ruby
# within the controller:

include Rectify::ControllerHelpers

def create
  present HomePresenter.new(:name => "Guest")

  RegisterAccount.call(@form) do
    on(:ok) { |user| expose(:name => user.name, :greeting => "Hello") }
  end
end
```

```erb
<!-- within the view: -->

<p><%= @greeting %> <%= presenter.name %></p>
# => <p>Hello Andy</p>
```

Take a look at [Wisper](https://github.com/krisleech/wisper) for more
information around how to do publish/subscribe.

## Presenters

A Presenter is a class that contains the presentational logic for your views.
These are also known as an "exhibit", "view model", "view object" or just a
"view" (Rails views are actually templates, but anyway). To avoid confusion
Rectify calls these classes Presenters.

It's often the case that you need some logic that is just for the UI. The same
question comes up, where should this logic go? You could put it directly in the
view, add it to the model or create a helper. Rectify's opinion is that all of
these are incorrect. Instead, create a Presenter for the view (or component of
the view) and place your logic here. These classes are easily testable and
provide a more object oriented approach to the problem.

To create a Presenter just derive off of `Rectify::Presenter`, add attributes as
you do for Form Objects using [Virtus](https://github.com/solnic/virtus)
`attribute` declaration. Inside a Presenter you have access to all view helper
methods so it's easy to move the presentation logic here:

```ruby
class UserDetailsPresenter < Rectify::Presenter
  attribute :user, User

  def edit_link
    return "" unless user.admin?

    link_to "Edit #{user.name}", edit_user_path(user)
  end
end
```

Once you have a Presenter, you typically create it in your controller and make
it accessible to your views. There are two ways to do that. The first way is to
just treat it as a normal class:

```ruby
class UsersController < ApplicationController
  def show
    user = User.find(params[:id])

    @presenter = UserDetailsPresenter.new(:user => user).attach_controller(self)
  end
end
```

You need to call `#attach_controller` and pass it a controller instance which will
allow it access to the view helpers. You can then use the Presenter in your
views as you would expect:

```erb
<p><%= @presenter.edit_link %></p>
```

The second way is a little cleaner as we have supplied a few helper methods to
clean up remove some of the boilerplate. You need to include the
`Rectify::ControllerHelpers` module and then use the `present` helper:

```ruby
class UsersController < ApplicationController
  include Rectify::ControllerHelpers

  def show
    user = User.find(params[:id])

    present UserDetailsPresenter.new(:user => user)
  end
end
```

In your view, you can access this presenter using the `presenter` helper method:

```erb
<p><%= presenter.edit_link %></p>
```

We recommend having a single Presenter per view but you may want to have more
than one presenter. You can use a Presenter to to hold the presentation logic
of your layout or for a component view. To do this, you can either use the first
method above or use the `present` method and add a `for` option with any key:

```ruby
class ApplicationController < ActionController::Base
  include Rectify::ControllerHelpers

  before_action { present LayoutPresenter.new(:user => user), :for => :layout }
end
```

To access this Presenter in the view, just pass the Presenter key to the
`presenter` method like so:

```erb
<p><%= presenter(:layout).login_link %></p>
```

### Updating values of a Presenter

After a presenter has been instantiated you can update it's values by just
setting their attributes:

```ruby
class UsersController < ApplicationController
  include Rectify::ControllerHelpers

  def show
    user = User.find(params[:id])

    present UserDetailsPresenter.new(:user => user)
    presenter.user = User.first
  end

  # or...

  def other_action
    user = User.find(params[:id])

    @presenter = UserDetailsPresenter.new(:user => user).attach_controller(self)
    @presenter.user = User.first
  end
end
```

As mentioned above in the Commands section, you can use the `expose` method (if
you include `Rectify::ControllerHelpers`). You can use this anywhere in the
controller action including the Command handler block. If you have set a
Presenter for the view then `expose` will try to set an attribute on that
presenter. If there is no Presenter or the Presenter doesn't have a matching
attribute then `expose` will set an instance variable of the same name:

```ruby
class UsersController < ApplicationController
  include Rectify::ControllerHelpers

  def show
    user = User.find(params[:id])

    present UserDetailsPresenter.new(:user => user)

    expose(:user => User.first, :message => "Hello there!")

    # presenter.user == User.first
    # @message == "Hello there!"
  end
end
```

### Decorators

Another option for containing your UI logic is to use a Decorator. Rectify
doesn't ship with a built in way to create a decorator but we recommend either
using [Draper](https://github.com/drapergem/draper) or you can roll your own
using `SimpleDelegator`:

```ruby
class UserDecorator < SimpleDelegator
  def full_name
    "#{first_name} #{last_name}"
  end
end

user = User.new(:first_name => "Andy", :last_name => "Pike")
decorator = UserDecorator.new(user)
decorator.full_name # => "Andy Pike"
```

If you want to decorate a collection of objects you can do that by adding the
`for_collection` method:

```ruby
class UserDecorator < SimpleDelegator
  # ...

  def self.for_collection(users)
    users.map { |u| new(u) }
  end
end

users = UserDecorator.for_collection(User.all)
user.each do |u|
  u.full_name # => Works for each user :o)
end
```

## Query Objects

The final main component to Rectify is the Query Object. It's role is to
encapsulate a single database query and any logic that it query needs to
operate. It still uses ActiveRecord but adds some very light sugar on the top to
make this style of architecture easier. This helps to keep your model classes
lean and gives a natural home to this code.

To create a query object, you create a new class and derive off of
`Rectify::Query`. The only thing you need to do is to implement the
`#query` method and return an `ActiveRecord::Relation` object from it:

```ruby
class ActiveUsers < Rectify::Query
  def query
    User.where(:active => true)
  end
end
```

To use this object, you just instantiate it and then use one of the following
methods to make use of it:

```ruby
ActiveUsers.new.count   # => Returns the number of records
ActiveUsers.new.first   # => Returns the first record
ActiveUsers.new.exists? # => Returns true if there are any records, else false
ActiveUsers.new.none?   # => Returns true if there are no records, else false
ActiveUsers.new.to_a    # => Execute the query and returns the resulting objects
ActiveUsers.new.each do |user| # => Iterates over each result
  puts user.name
end
ActiveUsers.new.map(&:age) # => All Enumerable methods
```

### Passing data to query objects

Passing data that your queries need to operate is best done via the constructor:

```ruby
class UsersOlderThan < Rectify::Query
  def initialize(age)
    @age = age
  end

  def query
    User.where("age > ?", @age)
  end
end

UsersOlderThan.new(25).count # => Returns the number of users over 25 years old
```

Sometimes your queries will need to do a little work with the provided data
before they can use it. Having your query encapsulated in an object makes this
easy and maintainable (here's a trivial example):

```ruby
class UsersWithBlacklistedEmail < Rectify::Query
  def initialize(blacklist)
    @blacklist = blacklist
  end

  def query
    User.where(:email => blacklisted_emails)
  end

  private

  def blacklisted_emails
    @blacklist.map { |b| b.email.strip.downcase }
  end
end
```

### Composition

One of this great features of ActiveRecord is the ability to easily compose
queries together in a simple way which helps reusability. Rectify Query Objects
can also be combined to created composed queries using the `|` operator as we
use in Ruby for Set Union. Here's how it looks:

```ruby
active_users_over_20 = ActiveUsers.new | UsersOlderThan.new(20)

active_users_over_20.count # => Returns number of active users over 20 years old
```

You can union many queries in this manner which will result in another
`Rectify::Query` object that you can use just like any other. This results in a
single database query.

As an alternative you can also use the `#merge` method which is simply an alias
of the `|` operator:

```ruby
active_users_over_20 = ActiveUsers.new.merge(UsersOlderThan.new(20))

active_users_over_20.count # => Returns number of active users over 20 years old
```

The `.merge` class method of `Rectify::Query` accepts multiple `Rectify::Query` objects to union together.  This is the same as using the `|` operator on multiple `Rectify::Query` objects.

```ruby
active_users_over_20 = Rectify::Query.merge(
  ActiveUsers.new,
  UsersOlderThan.new(20)
)

active_users_over_20.count # => Returns number of active users over 20 years old
```

You can also pass a `Rectify::Query` object into the constructor of another `Rectify::Query` object to set it as the base scope.

```ruby
class UsersOlderThan < Rectify::Query
  def initialize(age, scope = AllUsers.new)
    @age   = age
    @scope = scope
  end

  def query
    @scope.query.where("age > ?", @age)
  end
end

UsersOlderThan.new(20, ActiveUsers.new).count
```

### Leveraging your database

Using `ActiveRecord::Relation` is a great way to construct your database queries
but sometimes you need to to use features of your database that aren't supported
by ActiveRecord directly. These are usually database specific and can greatly
improve your query efficiency. When that happens, you will need to write some
raw SQL. Rectify Query Objects allow for this. In addition to your `#query`
method returning an `ActiveRecord::Relation` you can also return an array of
objects. This means you can run raw SQL using
`ActiveRecord::Querying#find_by_sql`:

```ruby
class UsersOverUsingSql < Rectify::Query
  def initialize(age)
    @age = age
  end

  def query
    User.find_by_sql([
      "SELECT * FROM users WHERE age > :age ORDER BY age ASC", { :age => @age }
    ])
  end
end
```

When you do this, the normal `Rectify::Query` methods are available but they
operate on the returned array rather than on the `ActiveRecord::Relation`. This
includes composition using the `|` operator but you can't compose an
`ActiveRecord::Relation` query object with one that returns an array of objects
from its `#query` method. You can compose two queries where both return arrays
but be aware that this will query the database for each query object and then
perform a Ruby array set union on the results. This might not be the most
efficient way to get the results so only use this when you are sure it's the
right thing to do.

The above example is fine for short SQL statements but if you are using raw SQL,
they will probably be much longer than a single line. Rectify provides a small
module that you can include to makes your query objects cleaner:

```ruby
class UsersOverUsingSql < Rectify::Query
  include Rectify::SqlQuery

  def initialize(age)
    @age = age
  end

  def model
    User
  end

  def sql
    <<-SQL.strip_heredoc
      SELECT *
      FROM users
      WHERE age > :age
      ORDER BY age ASC
    SQL
  end

  def params
    { :age => @age }
  end
end
```

Just include `Rectify::SqlQuery` in your query object and then supply the a
`model` method that returns the model of the returned objects. A
`params` method that returns a hash containing named parameters that the SQL
statement requires. Lastly, you must supply a `sql` method that returns the raw
SQL. We recommend using a heredoc which makes the SQL much cleaner and easier
to read. Parameters use the ActiveRecord standard symbol notation as shown above
with the `:age` parameter.

### Stubbing Query Objects in tests

Now that you have your queries nicely encapsulated, it's now easier with a clear
division of responsibility to improve how you use the database within your
tests. You should unit test your Query Objects to ensure they return the correct
data from a know database state.

What you can now do it stub out these database calls when you use them in other
classes. This improves your test code in a couple of ways:

1. You need less database setup code within your tests. Normally you might use
something like factory_girl to create records in your database and then when
your tests run they query this set of data. Stubbing the queries within your
tests can reduce this complexity.
2. Fewer database queries running and less factory usage means that your tests
3. are doing less work and therefore will run a bit faster.

In Rectify, we provide the RSpec helper method `stub_query` that will make
stubbing Query Objects easy:

```ruby
# inside spec/rails_helper.rb

require "rectify/rspec"

RSpec.configure do |config|
  # snip ...

  config.include Rectify::RSpec::Helpers
end

# within a spec:

it "returns the number of users" do
  stub_query(UsersOlderThan, :results => [User.new, User.new])

  expect(subject.awesome_method).to eq(2)
end
```

As a convenience `:results` accepts either an array of objects or a single
instance:

```ruby
stub_query(UsersOlderThan, :results => [User.new, User.new])
stub_query(UsersOlderThan, :results => User.new)
```

## Where do I put my files?

The next inevitable question is "Where do I put my Forms, Commands, Queries and
Presenters?". You could create `forms`, `commands`, `queries` and `presenters`
folders and follow the Rails Way. Rectify suggests grouping your classes by
feature rather than by pattern. For example, create a folder called `core` (this
can be anything) and within that, create a folder for each broad feature of your
application. Something like the following:

```
.
└── app
    ├── controllers
    ├── core
    │   ├── billing
    │   ├── fulfillment
    │   ├── ordering
    │   ├── reporting
    │   └── security
    ├── models
    └── views
```

Then you would place your classes in the appropriate feature folder. If you
follow this pattern remember to namespace your classes with a matching module
which will allow Rails to load them:

```ruby
# in app/core/billing/send_invoice.rb

module Billing
  class SendInvoice < Rectify::Command
    # ...
  end
end
```

You don't need to alter your load path as everything in the `app` folder is
loaded automatically.

As stated above, if you prefer not to use this method of organizing your code
then that is totally fine. Just create folders under `app` for the things in
Rectify that you use:

```
.
└── app
    ├── commands
    ├── controllers
    ├── forms
    ├── models
    ├── presenters
    ├── queries
    └── views
```

You don't need to make any configuration changes for your preferred folder
structure, just use whichever you feel most comfortable with.

## Trade offs

This style of Rails architecture is not a silver bullet for all projects. If
your app is pretty much just basic CRUD then you are unlikely to get much
benefit from this. However, if your app is more than just CRUD then you should
see an improvement in code structure and maintainability.

The downside to this approach is that there will be many more classes and files
to deal with. This can be tricky as the application gets bigger to hold the
whole system in your head. Personally I would prefer that as maintaining it will
be easier as all code around a specific user task is on one place.

Before you use these methods in your project, consider the trade off and use
these strategies where they make sense for you and your project. It maybe most
pragmatic to use a mixture of the classic Rails Way and the Rectify approach
depending on the complexity of different areas of your application.

## Developing Rectify

Some tests (specifically for Query objects) we need access to a database that
ActiveRecord can connect to. We use SQLite for this at present. When you run the
specs with `bundle exec rspec`, the database will be created for you.

There are some Rake tasks to help with the management of this test database
using normal(ish) commands from Rails:

```sh
rake db:migrate   # => Migrates the test database
rake db:schema    # => Dumps database schema
rake g:migration  # => Create a new migration file (use snake_case name)
```

### Releasing a new version

Bump the version in `lib/rectify/version.rb` then do the following:

```
bundle
gem build rectify.gemspec
gem push rectify-0.0.0.gem
```
