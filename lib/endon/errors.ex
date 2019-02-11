defmodule Endon.ValidationError do
  defexception message: "A validation error has occurred", changeset: nil
end

defmodule Endon.RecordNotFoundError do
  defexception message: "Could not find record"
end
