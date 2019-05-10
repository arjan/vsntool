defmodule Vsntool.MixProject do
  use Mix.Project

  def project do
    [
      app: :vsntool,
      version: File.read!("VERSION"),
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Vsntool],
      deps: deps()
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
      {:jason, "~> 1.0"}
    ]
  end
end
