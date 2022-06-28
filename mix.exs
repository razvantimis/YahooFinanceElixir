defmodule YahooFinanceElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :yahoo_finance_elixir,
      version: "0.1.4",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mtanca/YahooFinanceElixir",
      description: description(),
      package: package(),
      name: "Yahoo-Finance Elixir"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp description do
    "A simple elixir wrapper around Yahoo-Finance for historical and real-time stock quotes & data."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8.1"},
      {:poison, "~> 5.0"},
      {:ex_doc, ">= 0.28.4", only: :dev}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mtanca/YahooFinanceElixir"},
      maintainers: ["Mark T"]
    ]
  end
end
