defmodule Muscat.MixProject do
  use Mix.Project

  @url "https://github.com/smartepsh/muscat"
  def project do
    [
      app: :muscat,
      version: "0.1.0",
      elixir: "~> 1.11",
      description: "A library for solve simple equation.",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @url,
      docs: docs()
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "muscat",
      maintainers: ["Kenton Wang"],
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
