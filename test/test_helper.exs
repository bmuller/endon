ExUnit.start()

defmodule UserHelpers do
  use ExUnit.Case

  def i(query) do
    assert "#Ecto.Query<" <> rest = inspect(query)
    size = byte_size(rest)
    assert ">" = :binary.part(rest, size - 1, 1)
    :binary.part(rest, 0, size - 1)
  end
end

defmodule UserSingle do
  import UserHelpers

  defmodule Repo do
    def one(input), do: i(input)
    def all(input), do: [i(input)]
  end

  use Endon, repo: Repo
  use Ecto.Schema
  schema("users", do: nil)
end

defmodule UserNone do
  import UserHelpers

  defmodule Repo do
    def one(_input), do: nil
    def all(_input), do: []
  end

  use Endon, repo: Repo
  use Ecto.Schema
  schema("users", do: nil)
end

defmodule UserDouble do
  import UserHelpers

  defmodule Repo do
    def one(input), do: [i(input), nil]
    def all(input), do: [i(input), nil]
  end

  use Endon, repo: Repo
  use Ecto.Schema
  schema("users", do: nil)
end

defmodule UserOK do
  defmodule Repo do
    def update(input), do: {:ok, input}
    def insert(input), do: {:ok, input}
    def delete(input), do: {:ok, input}
  end

  use Endon, repo: Repo
  use Ecto.Schema
  schema("users", do: nil)
end

defmodule UserError do
  defmodule Repo do
    def update(input), do: {:error, input}
    def insert(input), do: {:error, input}
    def delete(input), do: {:error, %{input: input, errors: "sorry"}}
  end

  use Endon, repo: Repo
  use Ecto.Schema
  schema("users", do: nil)
end
