defmodule Endon.MixProject do
  use Mix.Project

  @version "1.0.0"

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
      source_url: "https://github.com/bmuller/endon",
      docs: [
        extra_section: "GUIDES",
        source_ref: "v#{@version}",
        main: "overview",
        formatters: ["html"],
        extras: extras()
      ]
    ]
  end

  defp extras do
    [
      "guides/overview.md",
      "guides/features.md"
    ]
  end

  defp aliases do
    [
      test: [
        "format --check-formatted",
        "test",
        "credo"
      ]
    ]
  end

  def package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bmuller/endon"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ex_doc, "~> 0.21", only: :dev},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
