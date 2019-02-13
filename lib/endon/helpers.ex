defmodule Endon.Helpers do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Ecto.Query

  alias Endon.{ValidationError, RecordNotFoundError}

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

  def find(repo, module, ids, opts) when is_list(ids) do
    [pk] = module.__schema__(:primary_key)
    result = where(repo, module, [{pk, ids}], opts)

    if length(result) == length(ids) do
      result
    else
      sids = Enum.join(Enum.map(ids, &to_string/1), ", ")

      raise RecordNotFoundError,
        message: "One or more values for #{pk} in list (#{sids}) could not be found"
    end
  end

  def find(repo, module, id, opts) do
    find(repo, module, [id], opts) |> hd
  end

  def find_or_create_by(repo, module, conditions) do
    case where(repo, module, Enum.into(conditions, []), limit: 1) do
      [result] ->
        {:ok, result}

      [] ->
        create(repo, module, conditions)
    end
  end

  def find_in_batches(repo, module, func, opts, conditions) do
    {start, opts} = Keyword.pop(opts, :start, 0)
    {finish, opts} = Keyword.pop(opts, :finish)
    {limit, opts} = Keyword.pop(opts, :batch_size, 1000)
    batch_iter(repo, module, start, finish, limit, conditions, func, opts)
  end

  defp batch_iter(repo, module, start, finish, limit, conditions, func, opts) do
    [pk] = module.__schema__(:primary_key)

    base = module |> add_where(conditions)

    query =
      if is_nil(finish) do
        from(x in base,
          where: field(x, ^pk) >= ^start,
          limit: ^limit,
          order_by: [asc: ^pk]
        )
      else
        from(x in base,
          where: field(x, ^pk) >= ^start and field(x, ^pk) <= ^finish,
          limit: ^limit,
          order_by: [asc: ^pk]
        )
      end

    results = query |> add_opts(opts, [:preload]) |> repo.all

    cond do
      length(results) == limit ->
        func.(results)
        lastid = Map.get(hd(Enum.take(results, -1)), pk)
        batch_iter(repo, module, lastid + 1, finish, limit, conditions, func, opts)

      length(results) > 0 ->
        func.(results)

      true ->
        nil
    end
  end

  def find_by(repo, module, conditions, opts) do
    module
    |> add_where(conditions)
    |> add_opts([limit: 1] ++ opts, [:limit, :preload])
    |> repo.one
  end

  def find_each(repo, module, func, opts, conditions) do
    find_in_batches(
      repo,
      module,
      fn batch ->
        Enum.each(batch, func)
      end,
      opts,
      conditions
    )
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

  def first(repo, module, opts) do
    [pk] = module.__schema__(:primary_key)
    opts = Keyword.merge([limit: 1, order_by: [asc: pk]], opts)
    result = where(repo, module, [], opts)
    if opts[:limit] == 1, do: first_or_nil(result), else: result
  end

  def last(repo, module, opts) do
    [pk] = module.__schema__(:primary_key)
    opts = Keyword.merge([order_by: [desc: pk]], opts)
    first(repo, module, opts)
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

    apply_opt(query, f, v) |> add_opts(rest, allowed_opts)
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
    from(x in query, where: field(x, ^f) in ^v)
    |> add_where(rest)
  end

  defp add_where(query, [{f, nil} | rest]) do
    from(x in query, where: is_nil(field(x, ^f)))
    |> add_where(rest)
  end

  defp add_where(query, [{f, v} | rest]) do
    query
    |> Query.where(^[{f, v}])
    |> add_where(rest)
  end
end
