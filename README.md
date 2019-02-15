# Endon
[![Build Status](https://secure.travis-ci.org/bmuller/endon.png?branch=master)](https://travis-ci.org/bmuller/endon)
[![Hex pm](http://img.shields.io/hexpm/v/endon.svg?style=flat)](https://hex.pm/packages/endon)

Endon is an Elixir library that provides helper functions for [Ecto](https://hexdocs.pm/ecto/getting-started.html#content), with inspiration from Ruby on Rails' [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html).  It's designed to be used within a module that is an `Ecto.Schema` and provides helpful functions.

## But why, isn't Ecto great?
Yes, Ecto is great.  But there are a few things that are really annoying, and a little syntactic sugar can go a long way.

1. What if I want to [paginate through a massive query](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches)?
1. Or [find records based on a few primary key values](https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)?
1. Or limit the number of records deleted from a query?
1. Or deal with [one to many / many to many](https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html) relationships?

There are a few [other](https://github.com/meyercm/base_model) [examples](http://rocket-science.ru/hacking/2018/10/30/active-record-smell-in-elixir) of starts to bringing some helpful methods to Ecto, but none are quite complete or work with Ecto 3.

## Installation

To install Endon, just add an entry to your `mix.exs`:

``` elixir
def deps do
  [
    # ...
    {:endon, "~> 0.1"}
  ]
end
```

(Check [Hex](https://hex.pm/packages/endon) to make sure you're using an up-to-date version number.)

## Configuration

In your `config/config.exs` you can set a few options:

``` elixir
config :endon,
  repo: MyModule.Repo
```

The `repo` should be the name of the [Ecto.Repo](https://hexdocs.pm/ecto/Ecto.Repo.html) in your application.

## Usage

To get started, add `use Endon` to each module where you'd like to use it.  For example:

``` elixir
defmodule User do
  use Endon
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :age, :integer, default: 0
    has_many :posts, Post
  end
end
```

Once Endon has been included, you can immediately use the helpful methods.

``` elixir
# get all users
user = User.all()

# get first user
user = User.first()

# get a user by id
user = User.find(1)

# Iterate through all users in the DB efficiently (paginated, results are queried in
# batches) and process them using a Stream
Enum.each(User.stream_where(), &User.do_some_processing/1)

# get a user by an attribute
user = User.find_by(name: "billy")

# get the count of users
count = User.count()

# create a new user
user = User.create!(name: "snake", age: 12)

# update that user
User.update!(user, age: 23)

# find all users that match criteria and preload Posts
User.where([age: 23], preload: :posts)

# page through all users in batches
User.find_in_batches(fn batch ->
  # we'll have a batch of 1,000 users here
  Enun.each(batch, fn user ->
    User.do_some_processing(user)
  end)
end)
```

## Running Tests

To run tests:

``` shell
$> mix test
```

## Reporting Issues

Please report all issues [on github](https://github.com/bmuller/endon/issues).
