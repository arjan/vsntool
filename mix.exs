defmodule Vsntool.MixProject do
  use Mix.Project

  @source_url "https://github.com/arjan/vsntool"
  @version File.read!("VERSION")

  def project do
    [
      app: :vsntool,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Vsntool],
      deps: deps(),
      package: package()
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
      {:jason, "~> 1.0"},
      {:porcelain, "~> 2.0"}
    ]
  end

  defp package do
    [
      description: "Lean-and-mean version bumping tool",
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
