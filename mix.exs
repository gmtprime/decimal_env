defmodule DecimalEnv.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :decimal_env,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     docs: docs,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:decimal, "~> 1.2"},
     {:earmark, ">= 0.0.0", only: :dev},
     {:ex_doc, "~> 0.13", only: :dev},
     {:credo, "~> 0.4.8", only: [:dev, :docs]},
     {:inch_ex, ">= 0.0.0", only: [:dev, :docs]}]
  end

  defp docs do
    [source_url: "https://github.com/gmtprime/decimal_env",
     source_ref: "v#{@version}",
     main: DecimalEnv]
  end

  defp description do
    """
    Provides macros to use Decimals with the regular Elixir operators
    """
  end

  defp package do
    [maintainers: ["Alexander de Sousa"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/gmtprime/decimal_env"}]
  end
end
