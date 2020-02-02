defmodule Callbacks do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :before_callbacks, accumulate: true)
      import Callbacks
    end
  end

  defmacro before_create(name, opts \\ []) do
    quote do
      @before_callbacks {unquote(name), unquote(opts)}
    end
  end
end

defmodule Blah do
  use Callbacks

  before_create :run_before
  
  def test do
    IO.puts inspect(@before_callbacks)
  end
end

Blah.test
