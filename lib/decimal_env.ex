defmodule DecimalEnv do
  @moduledoc """
  This module provides macros to encapsulate `Decimal` operations while using
  Elixir arithmetic and comparison operators and functions.
  """

  @typedoc """
  Type name.
  """
  @type type_name ::
          nil
          | :decimal
          | :float
          | :integer
          | :string
          | :scientific
          | :xsd
          | :raw

  @typedoc """
  Context.
  """
  @type context ::
          nil
          | keyword()
          | Decimal.Context.t()

  @typedoc """
  Output type.
  """
  @type output ::
          integer()
          | float()
          | binary()
          | Decimal.t()

  @typedoc """
  Option.
  """
  @type option ::
          {:as, type_name()}
          | {:context, context()}

  @typedoc """
  Options.
  """
  @type options :: [option()]

  @doc """
  Runs a block under the `Decimal` environment. All numeric values will be
  converted to `Decimal`.

  Options:
    - `:context` - `Decimal.Context` struct. it can also be a `keyword` list.
    - `:as` - In which type we should have the result. The possible values are
      the following:
      + `:decimal` (default)
      + `:float`
      + `:integer`
      + `:string`
      + `:xsd`
      + `:raw`
      + `:scientific`

  ## Examples

      iex> import DecimalEnv
      iex> decimal do: 42.42
      #Decimal<42.42>
      iex> decimal do: 84.0 - 21 - "21"
      #Decimal<42.0>
      iex> decimal as: :scientific do
      ...>   "0.0000000002" + 0.000000004
      ...> end
      "4.2E-9"
      iex> decimal context: [precision: 2, rounding: :ceiling], as: :integer do
      ...>   21.1 + 20
      ...> end
      42
  """
  @spec decimal(Macro.t()) :: Macro.t()
  @spec decimal(options(), Macro.t()) :: Macro.t()
  defmacro decimal(options \\ [], do: block) do
    quote do
      Decimal.Context.with(
        DecimalEnv.get_context(unquote(options[:context])),
        fn ->
          use DecimalEnv.Operators

          result = DecimalEnv.Operators.+(unquote(block))

          DecimalEnv.convert_type(result, unquote(options[:as]))
        end
      )
    end
  end

  #########
  # Helpers

  @doc false
  @spec get_context(nil | keyword() | Decimal.Context.t()) ::
          Decimal.Context.t()
  def get_context(context)

  def get_context(nil) do
    Decimal.Context.get()
  end

  def get_context(options) when is_list(options) do
    options =
      Decimal.Context.get()
      |> Map.from_struct()
      |> Map.to_list()
      |> Keyword.merge(options)

    struct(Decimal.Context, options)
  end

  def get_context(%Decimal.Context{} = context) do
    context
  end

  @doc false
  @spec convert_type(Decimal.t(), type_name()) :: output()
  def convert_type(decimal, type)

  def convert_type(decimal, :decimal), do: decimal
  def convert_type(decimal, :float), do: Decimal.to_float(decimal)
  def convert_type(decimal, :integer), do: Decimal.to_integer(decimal)
  def convert_type(decimal, :string), do: Decimal.to_string(decimal, :normal)
  def convert_type(decimal, :scientific), do: Decimal.to_string(decimal)
  def convert_type(decimal, :xsd), do: Decimal.to_string(decimal, :xsd)
  def convert_type(decimal, :raw), do: Decimal.to_string(decimal, :raw)
  def convert_type(decimal, _), do: decimal
end
