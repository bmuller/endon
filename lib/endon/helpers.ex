defmodule Endon.Helpers do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Ecto.Query

  alias Endon.{RecordNotFoundError, ValidationError}

  def all(repo, module, opts) do
    module
    |> add_opts(opts, [:order_by, :preload, :offset])
    |> repo.all()
  end

  def exists?(repo, module, conditions) do
    case where(repo, module, conditions, limit: 1) do
      [] ->
        false

      [_] ->
        true
    end
  end

  def delete(repo, _module, struct) do
    struct |> repo.delete()
  end

  def delete!(repo, module, struct) do
    case delete(repo, module, struct) do
      {:ok, result} ->
        result

      {:error, changeset} ->
        raise ValidationError,
          message: "Could not delete #{module}: #{inspect(changeset.errors)}",
          changeset: changeset
    end
  end

  def delete_where(repo, module, conditions) do
    module
    |> add_where(conditions)
    |> repo.delete_all
  end

  def find(repo, module, ids, opts) do
    case fetch(repo, module, ids, opts) do
      {:ok, result} ->
        result

      :error ->
        [pk] = module.__schema__(:primary_key)
        raise RecordNotFoundError, message: "One or more values for #{pk} could not be found"
    end
  end

  def fetch(repo, module, ids, opts) when is_list(ids) do
    [pk] = module.__schema__(:primary_key)
    result = where(repo, module, [{pk, ids}], opts)
    if length(result) == length(ids), do: {:ok, result}, else: :error
  end

  def fetch(repo, module, id, opts) do
    case fetch(repo, module, [id], opts) do
      {:ok, results} ->
        {:ok, hd(results)}

      :error ->
        :error
    end
  end

  def find_or_create_by(repo, module, conditions) do
    case where(repo, module, Enum.into(conditions, []), limit: 1) do
      [result] ->
        {:ok, result}

      [] ->
        create(repo, module, conditions)
    end
  end

  def stream_where(repo, module, conditions, opts) do
    [pk] = module.__schema__(:primary_key)
    {start, opts} = Keyword.pop(opts, :start, 0)
    {finish, opts} = Keyword.pop(opts, :finish)
    {limit, opts} = Keyword.pop(opts, :batch_size, 1000)
    basequery = module |> add_where(conditions) |> add_opts(opts, [:preload])

    query =
      if is_nil(finish) do
        from(x in basequery, limit: ^limit, order_by: [asc: ^pk])
      else
        from(x in basequery, where: field(x, ^pk) <= ^finish, limit: ^limit, order_by: [asc: ^pk])
      end

    initparams = %{
      pk: pk,
      repo: repo,
      start: start,
      query: query,
      more_possible: true,
      limit: limit
    }

    Stream.resource(fn -> initparams end, &stream_iter/1, & &1)
  end

  defp stream_iter(%{more_possible: false}), do: {:halt, nil}

  defp stream_iter(
         %{pk: pk, repo: repo, start: start, query: query, more_possible: true, limit: limit} =
           params
       ) do
    case repo.all(from(x in query, where: field(x, ^pk) >= ^start)) do
      [] ->
        {:halt, nil}

      results ->
        lastid = Map.get(hd(Enum.take(results, -1)), pk)
        {results, %{params | start: lastid + 1, more_possible: length(results) == limit}}
    end
  end

  def find_by(repo, module, conditions, opts) do
    module
    |> add_where(conditions)
    |> add_opts([limit: 1] ++ opts, [:limit, :preload])
    |> repo.one
  end

  def where(repo, module, conditions, opts) do
    module
    |> add_where(conditions)
    |> add_opts(opts, [:limit, :order_by, :offset, :preload])
    |> repo.all
  end

  def aggregate(repo, module, column, aggregate, conditions) do
    [pk] = module.__schema__(:primary_key)

    module
    |> add_where(conditions)
    |> repo.aggregate(aggregate, column || pk)
  end

  def update(repo, module, struct, params) do
    struct
    |> changeset(params, module)
    |> repo.update()
  end

  def update!(repo, module, struct, params) do
    case update(repo, module, struct, params) do
      {:ok, result} ->
        result

      {:error, changeset} ->
        raise ValidationError,
          message: "Could not create #{module}: #{inspect(changeset.errors)}",
          changeset: changeset
    end
  end

  def update_where(repo, module, params, conditions) do
    module
    |> add_where(conditions)
    |> repo.update_all(set: params)
  end

  def first(repo, module, conditions, opts) do
    opts = Keyword.merge([limit: 1], opts)
    result = where(repo, module, conditions, opts)
    if opts[:limit] == 1, do: first_or_nil(result), else: result
  end

  def last(repo, module, conditions, opts) do
    [pk] = module.__schema__(:primary_key)
    opts = Keyword.merge([limit: 1, order_by: [desc: pk]], opts)
    result = where(repo, module, conditions, opts)
    if opts[:limit] == 1, do: first_or_nil(result), else: result
  end

  def create(repo, module, params) do
    module.__struct__
    |> changeset(params, module)
    |> repo.insert()
  end

  def create!(repo, module, params) do
    case create(repo, module, params) do
      {:ok, result} ->
        result

      {:error, changeset} ->
        raise ValidationError,
          message: "Could not create #{module}: #{inspect(changeset.errors)}",
          changeset: changeset
    end
  end

  def scope(query, conditions) do
    add_where(query, conditions)
  end

  # private
  defp changeset(struct, attributes, module) do
    if Kernel.function_exported?(module, :changeset, 2) do
      module.changeset(struct, attributes)
    else
      Ecto.Changeset.change(struct, attributes)
    end
  end

  defp first_or_nil([]), do: nil
  defp first_or_nil([first | _]), do: first

  defp add_opts(query, [], _allowed_opts), do: query

  defp add_opts(query, [{f, v} | rest], allowed_opts) do
    if f not in allowed_opts do
      raise ArgumentError, message: "Option :#{f} is not valid in this context"
    end

    query |> apply_opt(f, v) |> add_opts(rest, allowed_opts)
  end

  defp apply_opt(query, :order_by, order_by), do: Query.order_by(query, ^order_by)
  defp apply_opt(query, :limit, limit), do: Query.limit(query, ^limit)
  defp apply_opt(query, :preload, preload), do: Query.preload(query, ^preload)
  defp apply_opt(query, :offset, offset), do: Query.offset(query, ^offset)

  defp add_where(query, []), do: query
  # this works because we only ever call add_where with a first argument
  # of the struct itself
  defp add_where(_query, %Ecto.Query{} = conditions), do: conditions

  defp add_where(query, [{f, v} | rest]) when is_list(v) do
    query = from(x in query, where: field(x, ^f) in ^v)
    query |> add_where(rest)
  end

  defp add_where(query, [{f, nil} | rest]) do
    query = from(x in query, where: is_nil(field(x, ^f)))
    query |> add_where(rest)
  end

  defp add_where(query, [{f, v} | rest]) do
    query
    |> Query.where(^[{f, v}])
    |> add_where(rest)
  end
end
