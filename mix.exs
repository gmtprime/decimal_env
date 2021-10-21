defmodule DecimalEnv.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @root "https://github.com/gmtprime/decimal_env"

  def project do
    [
      app: :decimal_env,
      version: @version,
      elixir: "~> 1.12",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "DecimalEnv",
      dialyzer: dialyzer(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  #############
  # Application

  def application do
    [extra__applications: []]
  end

  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:ex_doc, "~> 0.25", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/decimal_env.plt"}
    ]
  end

  #########
  # Package

  defp description do
    """
    Provides macros to use Decimal with regular Elixir operators.
    """
  end

  defp package do
    [
      description: description(),
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", ".formatter.exs"],
      maintainers: ["Alexander de Sousa"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@root}/blob/master/CHANGELOG.md",
        "Github" => @root
      }
    ]
  end

  ###############
  # Documentation

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      source_url: @root,
      source_ref: "v#{@version}"
    ]
  end
end
