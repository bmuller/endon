defmodule Endon.MixProject do
  use Mix.Project

  @source_url "https://github.com/bmuller/endon"
  @version "1.0.2"

  def project do
    [
      app: :endon,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Ecto query helpers, inspired by ActiveRecord",
      package: package(),
      docs: docs()
    ]
  end

  defp aliases do
    [
      test: [
        "format --check-formatted",
        "credo",
        "test"
      ]
    ]
  end

  def package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ex_doc, "~> 0.24", only: :dev},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extra_section: "GUIDES",
      source_ref: "v#{@version}",
      source_url: @source_url,
      main: "readme",
      formatters: ["html"],
      extras: [
        "README.md",
        "guides/features.md"
      ]
    ]
  end
end
