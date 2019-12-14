defmodule Uiar.MixProject do
  use Mix.Project

  def project do
    [
      app: :uiar,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.7", runtime: false, only: [:dev]}
    ]
  end
end
