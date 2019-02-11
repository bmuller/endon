defmodule Endon do
  @moduledoc """
  Documentation for Endon.
  """

  defmacro __using__(opts \\ []) do
    repo = Keyword.get(opts, :repo, Application.get_env(:endon, :repo))

    quote bind_quoted: [repo: repo] do
      @repo repo

      def all(opts \\ []), do: Helpers.all(@repo, __MODULE__, opts)

      def where(conditions, opts \\ []), do: Helpers.where(@repo, __MODULE__, conditions, opts)
      def exists?(conditions), do: Helpers.exists?(@repo, __MODULE__, conditions)

      def find(id_or_ids, opts \\ []), do: Helpers.find(@repo, __MODULE__, id_or_ids, opts)
      def find_or_create(%{} = params), do: Helpers.find_or_create(@repo, __MODULE__, params)
      def find_or_create(params) when is_list(params), do: find_or_create(Enum.into(params, %{}))

      def find_in_batches(func, opts \\ [], conditions \\ []),
        do: Helpers.find_in_batches(@repo, __MODULE__, func, opts, conditions)

      def find_each(func, opts \\ [], conditions \\ []),
        do: Helpers.find_each(@repo, __MODULE__, func, opts, conditions)

      def count(conditions \\ []), do: Helpers.count(@repo, __MODULE__, conditions)
      def sum(column, conditions \\ []), do: Helpers.sum(@repo, __MODULE__, column, conditions)
      def avg(column, conditions \\ []), do: Helpers.avg(@repo, __MODULE__, column, conditions)
      def min(column, conditions \\ []), do: Helpers.min(@repo, __MODULE__, column, conditions)
      def max(column, conditions \\ []), do: Helpers.max(@repo, __MODULE__, column, conditions)

      def create(%{} = params), do: Helpers.create(@repo, __MODULE__, params)
      def create(params) when is_list(params), do: create(Enum.into(params, %{}))
      def create!(%{} = params), do: Helpers.create!(@repo, __MODULE__, params)
      def create!(params) when is_list(params), do: create!(Enum.into(params, %{}))

      def update(%__MODULE__{} = struct, %{} = params),
        do: Helpers.update(@repo, __MODULE__, struct, params)

      def update(%__MODULE__{} = struct, params) when is_list(params),
        do: update(struct, Enum.into(params, %{}))

      def update!(%__MODULE__{} = struct, %{} = params),
        do: Helpers.update!(@repo, __MODULE__, struct, params)

      def update!(%__MODULE__{} = struct, params) when is_list(params),
        do: update!(struct, Enum.into(params, %{}))

      def update_where(params, conditions \\ []),
        do: Helpers.update_where(@repo, __MODULE__, params, conditions)

      def delete(%__MODULE__{} = struct),
        do: Helpers.delete(@repo, __MODULE__, struct)

      def delete!(%__MODULE__{} = struct),
        do: Helpers.delete!(@repo, __MODULE__, struct)

      def delete!(%__MODULE__{} = struct, params) when is_list(params),
        do: delete!(struct, Enum.into(params, %{}))

      def delete_where(conditions \\ []), do: Helpers.delete_where(@repo, __MODULE__, conditions)

      def first(opts \\ []), do: Helpers.first(@repo, __MODULE__, opts)
      def last(opts \\ []), do: Helpers.last(@repo, __MODULE__, opts)
    end
  end
end
