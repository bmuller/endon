defmodule Endon do
  @moduledoc ~S"""
  Endon is an Elixir library that provides helper functions for [Ecto](https://hexdocs.pm/ecto/getting-started.html#content),
  with inspiration from Ruby on Rails' [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html).

  It's designed to be used within a module that is an Ecto.Schema and
  provides helpful functions.

  ## Example

      defmodule User do
        use Endon
        use Ecto.Schema

        schema "users" do
          field :name, :string
          field :age, :integer, default: 0
          has_many :posts, Post
        end
      end

  Once Endon has been included, you can immediately use the helpful methods below.  For instance:

      iex> user = User.find(1)
      iex> user = User.find_by(name: "billy")
      iex> count = User.count()
      iex> user = User.create!(name: "snake", age: 12)
      iex> User.update!(user, age: 23)
      iex> User.where([age: 23], preload: :posts)
  """

  alias Endon.{Helpers}

  @doc """
  Fetches all entries from the data store matching the given query.

  `opts` can be any of `:order_by`, `:preload`, or `:offset`
  """
  @spec all(opts :: keyword()) :: list(Ecto.Schema.t())
  def all(opts \\ []), do: doc!([opts])

  @doc """
  Fetch all entries that match the given conditions.

  The conditions can be a `Ecto.Query.t/0` or a `Keyword.t/0`.

  The options can be any of: `:limit`, `:order_by`, `:offset`, `:preload`.

  ## Examples
      
      iex> User.where(id: 1)
      iex> User.where(name: "billy", age: 23)
      iex> User.where([name: "billy", age: 23], limit: 10, order_by: [desc: :id])
      iex> query = from u in User, where: u.id > 10
      iex> User.where(query, limit: 1)
  """
  @spec where(keyword() | Ecto.Query.t(), keyword()) :: list(Ecto.Schema.t())
  def where(conditions, opts \\ []), do: doc!([conditions, opts])

  @doc """
  Checks if there exists an entry that matches the given query.

  `conditions` are the same as those accepted by `where/2`.
  """
  @spec exists?(keyword() | Ecto.Query.t()) :: boolean()
  def exists?(conditions), do: doc!([conditions])

  @doc """
  Fetches one or more structs from the data store based on the primary key(s) given.

  If one primary key is given, then one struct will be returned (or a `Endon.RecordNotFoundError`
  raised if a match isn't found).

  If more than one primary key is given in a list, then all of the structs with those ids
  will be returned (and a `Endon.RecordNotFoundError` will be raised if any one of the primary 
  keys can't be found).

  The only option that matters here is `:preload`.
  """
  @spec find(integer() | list(integer()), keyword()) :: list(Ecto.Schema.t()) | Ecto.Schema.t()
  def find(id_or_ids, opts \\ []), do: doc!([id_or_ids, opts])

  @doc """
  Find or create a record based on specific attributes values.

  Similar to `find_by`, except that if a record cannot be found with the given attributes
  then a new one will be created.

  Returns `{:ok, struct}` if one is found/created, or `{:error, changeset}` if there is
  a validation error.
  """
  @spec find_or_create_by(keyword() | struct()) :: Ecto.Schema.t()
  def find_or_create_by(params), do: doc!([params])

  @doc """
  Find a single record based on given conditions.

  If a record can't be found, then `nil` is returned.

  The only option that matters here is `:preload`.
  """
  @spec find_by(keyword(), keyword()) :: Ecto.Schema.t() | nil
  def find_by(conditions, opts \\ []), do: doc!([conditions, opts])

  @doc """
  Create a `Stream` that queries the data store in batches for matching records.

  This is useful for paginating through a very large result set in chunks.  The `Stream`
  is a composable, lazy enumerable that allows you to iterate through what could be a
  very large number of records efficiently.

  `opts` can be any of:
  * batch_size: Specifies the size of the batch. Defaults to 1000.
  * start: Specifies the primary key value to start from, inclusive of the value.
  * finish: Specifies the primary key value to end at, inclusive of the value.

  And `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).

  This function will only work for types that have a primary key that is an integer.

  ## Examples
      
      iex> Enum.each(User.stream_where(), &User.do_some_processing/1)

      iex> query = from u in User, where: u.id > 100
      iex> Enum.each(User.stream_where(query, batch_size: 10), fn user ->
      iex>   User.do_some_processing(user)
      iex> end)
  """
  @spec stream_where(keyword(), keyword()) :: Enumerable.t()
  def stream_where(conditions \\ [], opts \\ []), do: doc!([conditions, opts])

  @doc """
  Get a count of all records matching the conditions.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec count(keyword() | Ecto.Query.t()) :: integer()
  def count(conditions \\ []), do: doc!([conditions])

  @doc """
  Calculate the given aggregate over the given column.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec aggregate(atom(), :avg | :count | :max | :min | :sum, keyword() | Ecto.Query.t()) ::
          term() | nil
  def aggregate(column, aggregate, conditions \\ []), do: doc!([column, aggregate, conditions])

  @doc """
  Get the sum of a given column.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec sum(String.t() | atom(), keyword()) :: integer()
  def sum(column, conditions \\ []), do: doc!([column, conditions])

  @doc """
  Get the average of a given column.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec avg(String.t() | atom(), keyword()) :: float()
  def avg(column, conditions \\ []), do: doc!([column, conditions])

  @doc """
  Get the minimum value of a given column.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec min(String.t() | atom(), keyword()) :: float() | integer()
  def min(column, conditions \\ []), do: doc!([column, conditions])

  @doc """
  Get the maximum value of a given column.

  `conditions` are anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec max(String.t() | atom(), keyword()) :: float() | integer()
  def max(column, conditions \\ []), do: doc!([column, conditions])

  @doc """
  Insert a new record into the data store.

  `params` can be either a `Keyword` list or `Map` of attributes and values. 

  Returns `{:ok, struct}` if one is created, or `{:error, changeset}` if there is
  a validation error.
  """
  @spec create(keyword() | struct()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(params), do: doc!([params])

  @doc """
  Insert a new record into the data store.

  `params` can be either a `Keyword` list or `Map` of attributes and values. 

  Returns the struct if created, or raises a `Endon.ValidationError` if there was
  a validation error.
  """
  @spec create!(keyword() | struct()) :: Ecto.Schema.t()
  def create!(params), do: doc!([params])

  @doc """
  Update a record in the data store.

  The `struct` must be a `Ecto.Schema.t/0` (your module that uses `Ecto.Schema`).
  `params` can be either a `Keyword` list or `Map` of attributes and values. 

  Returns `{:ok, struct}` if one is created, or `{:error, changeset}` if there is
  a validation error.
  """
  @spec update(Ecto.Schema.t(), keyword() | struct()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(struct, params), do: doc!([struct, params])

  @doc """
  Update a record in the data store.

  The `struct` must be a `Ecto.Schema.t/0` (your module that uses `Ecto.Schema`).
  `params` can be either a `Keyword` list or `Map` of attributes and values. 

  Returns the struct if it was updated, or raises a `Endon.ValidationError` if there was
  a validation error.
  """
  @spec update!(Ecto.Schema.t(), keyword() | struct()) :: Ecto.Schema.t()
  def update!(struct, params), do: doc!([struct, params])

  @doc """
  Update multiple records in the data store based on conditions.

  Update all the records that match the given `conditions`, setting the given `params`
  as attributes.  `params` can be either a `Keyword` list or `Map` of attributes and values,
  and `conditions` is the same as for `where/2`.

  It returns a tuple containing the number of entries and any returned result as second element.
  The second element is nil by default unless a select is supplied in the update query.
  """
  @spec update_where(keyword(), keyword() | Ecto.Query.t()) :: {integer(), nil | [term()]}
  def update_where(params, conditions \\ []), do: doc!([params, conditions])

  @doc """
  Delete a record in the data store.

  The `struct` must be a `Ecto.Schema.t/0` (your module that uses `Ecto.Schema`).

  Returns `{:ok, struct}` if the record is deleted, or `{:error, changeset}` if there is
  a validation error.
  """
  @spec delete(Ecto.Schema.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(struct), do: doc!([struct])

  @doc """
  Delete a record in the data store.

  The `struct` must be a `Ecto.Schema.t/0` (your module that uses `Ecto.Schema`).

  Returns the struct if it was deleted, or raises a `Endon.ValidationError` if there was
  a validation error.
  """
  @spec delete!(Ecto.Schema.t()) :: Ecto.Schema.t()
  def delete!(struct), do: doc!([struct])

  @doc """
  Delete multiple records in the data store based on conditions.

  Delete all the records that match the given `conditions` (the same as for `where/2`).

  **Note:** If you don't supply any conditions, _all_ records will be deleted.

  It returns a tuple containing the number of entries and any returned result as second element.
  The second element is nil by default unless a select is supplied in the update query.
  """
  @spec delete_where(keyword()) :: {integer(), nil | [term()]}
  def delete_where(conditions \\ []), do: doc!([conditions])

  @doc """
  Get the first record, or `nil` if none are found.

  Find the first record (or first N records if a `:limit` opt parameter is supplied).
  If no order is defined it will order by primary key.

  `opts` can include `:limit` and `:order_by` (by default, orders by primary key ascending).
  `conditions` can be anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec first(keyword(), keyword()) :: Ecto.Schema.t() | nil
  def first(conditions \\ [], opts \\ []), do: doc!([conditions, opts])

  @doc """
  Get the last record, or `nil` if none are found.

  Find the last record (or last N records if a `:limit` opt parameter is supplied).
  If no order is defined it will order by primary key descending.

  `opts` can include `:limit` and `:order_by` (by default, orders by primary key descending).
  `conditions` can be anyting accepted by `where/2` (including a `Ecto.Query.t/0`).
  """
  @spec last(keyword(), keyword()) :: Ecto.Schema.t() | nil
  def last(conditions \\ [], opts \\ []), do: doc!([conditions, opts])

  defp doc!(_) do
    raise "The functions in Endon should not be invoked directly, they're for docs only"
  end

  defmacro __using__(opts \\ []) do
    repo = Keyword.get(opts, :repo, Application.get_env(:endon, :repo))

    quote bind_quoted: [repo: repo] do
      @repo repo

      def all(opts \\ []), do: Helpers.all(@repo, __MODULE__, opts)

      def where(conditions, opts \\ []), do: Helpers.where(@repo, __MODULE__, conditions, opts)
      def exists?(conditions), do: Helpers.exists?(@repo, __MODULE__, conditions)

      def find(id_or_ids, opts \\ []), do: Helpers.find(@repo, __MODULE__, id_or_ids, opts)

      def find_or_create_by(%{} = params),
        do: Helpers.find_or_create_by(@repo, __MODULE__, params)

      def find_or_create_by(params) when is_list(params),
        do: find_or_create_by(Enum.into(params, %{}))

      def find_by(conditions, opts \\ []),
        do: Helpers.find_by(@repo, __MODULE__, conditions, opts)

      def stream_where(conditions \\ [], opts \\ []),
        do: Helpers.stream_where(@repo, __MODULE__, conditions, opts)

      def aggregate(column, aggregate, conditions \\ []),
        do: Helpers.aggregate(@repo, __MODULE__, column, aggregate, conditions)

      def count(conditions \\ []), do: aggregate(nil, :count, conditions)
      def sum(column, conditions \\ []), do: aggregate(column, :sum, conditions)
      def avg(column, conditions \\ []), do: aggregate(column, :avg, conditions)
      def min(column, conditions \\ []), do: aggregate(column, :min, conditions)
      def max(column, conditions \\ []), do: aggregate(column, :max, conditions)

      def create(%{} = params), do: Helpers.create(@repo, __MODULE__, params)
      def create(params) when is_list(params), do: create(Enum.into(params, %{}))
      def create!(%{} = params), do: Helpers.create!(@repo, __MODULE__, params)
      def create!(params) when is_list(params), do: create!(Enum.into(params, %{}))

      def update(%{} = struct, %{} = params),
        do: Helpers.update(@repo, __MODULE__, struct, params)

      def update(%{} = struct, params) when is_list(params),
        do: update(struct, Enum.into(params, %{}))

      def update!(%{} = struct, %{} = params),
        do: Helpers.update!(@repo, __MODULE__, struct, params)

      def update!(%{} = struct, params) when is_list(params),
        do: update!(struct, Enum.into(params, %{}))

      def update_where(params, conditions \\ []),
        do: Helpers.update_where(@repo, __MODULE__, params, conditions)

      def delete(%{} = struct),
        do: Helpers.delete(@repo, __MODULE__, struct)

      def delete!(%{} = struct),
        do: Helpers.delete!(@repo, __MODULE__, struct)

      def delete_where(conditions \\ []), do: Helpers.delete_where(@repo, __MODULE__, conditions)

      def first(conditions \\ [], opts \\ []),
        do: Helpers.first(@repo, __MODULE__, conditions, opts)

      def last(conditions \\ [], opts \\ []),
        do: Helpers.last(@repo, __MODULE__, conditions, opts)
    end
  end
end
