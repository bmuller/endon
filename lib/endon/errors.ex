defmodule Endon.ValidationError do
  @moduledoc """
  An error thrown if there's a validation error in an `Ecto.Changeset`.  There's a `changeset` property that
  contains the `Ecto.Changeset` with the error.
  """
  defexception message: "A validation error has occurred", changeset: nil
end

defmodule Endon.RecordNotFoundError do
  @moduledoc """
  An error thrown if a record was expected but not found.
  """
  defexception message: "Could not find record"
end
