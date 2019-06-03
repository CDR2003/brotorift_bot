defmodule BrotoriftBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :brotorift_bot,
      version: "0.1.3",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      description: description(),
      name: "BrotoriftBot",
      source_url: "https://github.com/CDR2003/brotorift_bot"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BrotoriftBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:brotorift, "~> 0.4.4"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    "Brotorift bot for load testing."
  end

  defp package() do
    [
      name: "brotorift_bot",
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Peter Ren"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/CDR2003/brotorift_bot"}
    ]
  end
end
