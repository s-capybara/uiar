defmodule Uiar.MixProject do
  use Mix.Project

  def project do
    [
      app: :uiar,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: "Code formatter on use, import, alias and require",
      package: [
        maintainers: ["s-capybara"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/s-capybara/uiar"}
      ],
      docs: [main: "Uiar"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      name: "uiar",
      source_url: "https://github.com/s-capybara/uiar"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false}
    ]
  end
end
