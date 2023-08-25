defmodule MqttDimplexGw.MixProject do
  use Mix.Project

  def project do
    [
      app: :mqtt_dimplex_gw,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        mqtt_dimplex_gw: []
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MqttDimplexGw.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tortoise, "~> 0.10"},
      {:tesla, "~> 1.4"},
      {:jason, ">= 1.0.0"},
      {:mint, "~> 1.0"}
    ]
  end
end
