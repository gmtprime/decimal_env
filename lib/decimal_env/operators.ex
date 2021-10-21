defmodule DecimalEnv.Operators do
  @moduledoc """
  This module redefines Elixir's numeric operators so we can use `Decimal`
  seemlessly.
  """
  import Kernel,
    except: [
      abs: 1,
      min: 2,
      max: 2,
      div: 2,
      rem: 2,
      round: 1,
      ceil: 1,
      floor: 1,
      +: 1,
      +: 2,
      -: 1,
      -: 2,
      *: 2,
      /: 2,
      ==: 2,
      !=: 2,
      >: 2,
      >=: 2,
      <: 2,
      <=: 2
    ]

  @typedoc """
  Supported inputs.
  """
  @type input :: binary() | integer() | float() | Decimal.t()

  @doc """
  Imports the `Decimal` operators instead of the Kernel ones.
  """
  defmacro __using__(_options) do
    quote do
      import Kernel,
        except: [
          abs: 1,
          min: 2,
          max: 2,
          div: 2,
          rem: 2,
          round: 1,
          ceil: 1,
          floor: 1,
          +: 1,
          +: 2,
          -: 1,
          -: 2,
          *: 2,
          /: 2,
          ==: 2,
          !=: 2,
          >: 2,
          >=: 2,
          <: 2,
          <=: 2
        ]

      import DecimalEnv.Operators
    end
  end

  ########################
  # Mathematical functions

  @doc """
  The absolute value of given number. Sets the number's sign to positive.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> abs("42") == Decimal.new("42")
      true
      iex> abs("-42") == Decimal.new("42")
      true
      iex> abs(42) == Decimal.new("42")
      true
      iex> abs(-42) == Decimal.new("42")
      true
      iex> abs(42.0) == Decimal.new("42")
      true
      iex> abs(-42.0) == Decimal.new("42")
      true
  """
  @spec abs(input()) :: Decimal.t()
  def abs(number) do
    number
    |> to_decimal()
    |> Decimal.abs()
  end

  @doc """
  Compares two values numerically and returns the minimum.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> min("43", "42") == Decimal.new("42")
      true
      iex> min(43, 42) == Decimal.new("42")
      true
      iex> min(43.0, 42.0) == Decimal.new("42")
      true
      iex> min(43.0, "42.0") == Decimal.new("42")
      true
      iex> min(42.0, "43.0") == Decimal.new("42")
      true
  """
  @spec min(input(), input()) :: Decimal.t()
  def min(a, b) do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.min(a, b)
  end

  @doc """
  Compares two values numerically and returns the maximum.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> max("42", "41") == Decimal.new("42")
      true
      iex> max(42, 41) == Decimal.new("42")
      true
      iex> max(42.0, 41.0) == Decimal.new("42")
      true
      iex> max(42.0, "41.0") == Decimal.new("42")
      true
      iex> max(41.0, "42.0") == Decimal.new("42")
      true
  """
  @spec max(input(), input()) :: Decimal.t()
  def max(a, b) do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.max(a, b)
  end

  @doc """
  Divides two numbers and returns the integer part.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> div(5, 2) == Decimal.new("2")
      true
      iex> div("5", "2") == Decimal.new("2")
      true
      iex> div(5.0, 2.0) == Decimal.new("2")
      true
      iex> div(5.0, "2.0") == Decimal.new("2")
      true
  """
  @spec div(input(), input()) :: Decimal.t()
  def div(a, b) do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.div_int(a, b)
  end

  @doc """
  Remainder of integer division of two numbers. The result will have the sign
  of the first number.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> rem(5, 2) == Decimal.new("1")
      true
      iex> rem("5", "2") == Decimal.new("1")
      true
      iex> rem("5.0", "2.0") == Decimal.new("1")
      true
      iex> rem(5.0, "2.0") == Decimal.new("1")
      true
  """
  @spec rem(input(), input()) :: Decimal.t()
  def rem(a, b) do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.rem(a, b)
  end

  @doc """
  Finds the square root of a `number`.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> sqrt(4) == Decimal.new("2")
      true
      iex> sqrt("4") == Decimal.new("2")
      true
      iex> sqrt(4.0) == Decimal.new("2")
      true
  """
  @spec sqrt(input()) :: Decimal.t()
  def sqrt(number) do
    number = to_decimal(number)

    Decimal.sqrt(number)
  end

  @doc """
  Rounds the given `number` to specified decimal places with the given
  `strategy` (default is to round to nearest one). If `places` is negative, at
  least that many digits to the left of the decimal point will be zero.

  The available strategies are:

  - `:down`
  - `:half_up`
  - `:half_even`
  - `:ceiling`
  - `:floor`
  - `:half_down`
  - `:up`

  ## Examples

      iex> use DecimalEnv.Operators
      iex> round(42) == Decimal.new("42")
      true
      iex> round(41.5) == Decimal.new("42")
      true
      iex> round("41.5") == Decimal.new("42")
      true
      iex> round("42.4") == Decimal.new("42")
      true
  """
  @spec round(input()) :: Decimal.t()
  @spec round(input(), non_neg_integer()) :: Decimal.t()
  @spec round(input(), non_neg_integer(), Decimal.rounding()) :: Decimal.t()
  def round(number, places \\ 0, strategy \\ :half_up)

  def round(number, places, strategy) do
    number = to_decimal(number)

    Decimal.round(number, places, strategy)
  end

  @doc """
  Returns the smallest number larger than or equal to `number`.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> ceil(42) == Decimal.new("42")
      true
      iex> ceil("41.1") == Decimal.new("42")
      true
      iex> ceil(41.1) == Decimal.new("42")
      true
  """
  @spec ceil(input()) :: Decimal.t()
  def ceil(number) do
    number = to_decimal(number)

    round(number, 0, :ceiling)
  end

  @doc """
  Returns the largest number smaller than or equal to `number`.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> floor(42) == Decimal.new("42")
      true
      iex> floor("42.9") == Decimal.new("42")
      true
      iex> floor(42.9) == Decimal.new("42")
      true
  """
  @spec floor(input()) :: Decimal.t()
  def floor(number) do
    number = to_decimal(number)

    round(number, 0, :floor)
  end

  ######################
  # Arithmetic operators

  @doc """
  Generates infinity.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> inf() == Decimal.new("+Inf")
      true
      iex> -inf() == Decimal.new("-Inf")
      true
  """
  @spec inf() :: Decimal.t()
  def inf do
    Decimal.new("Infinity")
  end

  @doc """
  Arithmetic positive unary operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> +"42" == Decimal.new("42")
      true
      iex> +42 == Decimal.new("42")
      true
      iex> +42.0 == Decimal.new("42")
      true
  """
  @spec +input() :: Decimal.t()
  def +number do
    to_decimal(number)
  end

  @doc """
  Arithmetic negative unary operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> -"42" == Decimal.new("-42")
      true
      iex> -42 == Decimal.new("-42")
      true
      iex> -42.0 == Decimal.new("-42")
      true
  """
  @spec -input() :: Decimal.t()
  def -number do
    number
    |> to_decimal()
    |> Decimal.negate()
  end

  @doc """
  Arithmetic addition operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "21" + "21" == Decimal.new("42")
      true
      iex> 21 + 21 == Decimal.new("42")
      true
      iex> 21.0 + 21.0 == Decimal.new("42")
      true
      iex> 21.0 + "21.0" == Decimal.new("42")
      true
  """
  @spec input() + input() :: Decimal.t()
  def a + b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.add(a, b)
  end

  @doc """
  Arithmetic substraction operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "84" - "42" == Decimal.new("42")
      true
      iex> 84 - 42 == Decimal.new("42")
      true
      iex> 84.0 - 42.0 == Decimal.new("42")
      true
      iex> 84.0 - "42.0" == Decimal.new("42")
      true
  """
  @spec input() - input() :: Decimal.t()
  def a - b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.sub(a, b)
  end

  @doc """
  Arithmetic multiplication operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "21" * "2" == Decimal.new("42")
      true
      iex> 21 * 2 == Decimal.new("42")
      true
      iex> 21.0 * 2.0 == Decimal.new("42")
      true
      iex> 21.0 * "2.0" == Decimal.new("42")
      true
  """
  @spec input() * input() :: Decimal.t()
  def a * b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.mult(a, b)
  end

  @doc """
  Arithmetic division operator.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "84" / "2" == Decimal.new("42")
      true
      iex> 84 / 2 == Decimal.new("42")
      true
      iex> 84.0 / 2.0 == Decimal.new("42")
      true
      iex> 84.0 / "2.0" == Decimal.new("42")
      true
  """
  @spec input() / input() :: Decimal.t()
  def a / b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.div(a, b)
  end

  ######################
  # Comparison operators

  @doc """
  Whether a number is equal to the other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "42" == "42"
      true
      iex> 42 == 42
      true
      iex> 42.0 == 42.0
      true
      iex> 42.0 == "42.0"
      true
      iex> 42 == 41
      false
  """
  @spec input() == input() :: boolean()
  def a == b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.equal?(a, b)
  end

  @doc """
  Whether a number is not equal to the other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "42" != "41"
      true
      iex> 42 != 41
      true
      iex> 42.0 != 41.0
      true
      iex> 42.0 != "41.0"
      true
      iex> 42 != 42
      false
  """
  @spec input() != input() :: boolean()
  def a != b do
    a = to_decimal(a)
    b = to_decimal(b)

    not (a == b)
  end

  @doc """
  Whether a number is greater than than other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "42" > "41"
      true
      iex> 42 > 41
      true
      iex> 42.0 > 41.0
      true
      iex> 42.0 > "41.0"
      true
      iex> 41 > 42
      false
  """
  @spec input() > input() :: boolean()
  def a > b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.gt?(a, b)
  end

  @doc """
  Whether a number is greater than or equal to the other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "42" >= "41"
      true
      iex> 42 >= 41
      true
      iex> 42.0 >= 41.0
      true
      iex> 42.0 >= "41.0"
      true
      iex> 42 >= 42
      true
      iex> 41 >= 42
      false
  """
  @spec input() >= input() :: boolean()
  def a >= b do
    a = to_decimal(a)
    b = to_decimal(b)

    a > b or a == b
  end

  @doc """
  Whether a number is less than other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "41" < "42"
      true
      iex> 41 < 42
      true
      iex> 41.0 < 42.0
      true
      iex> 41.0 < "42.0"
      true
      iex> 42 < 41
      false
  """
  @spec input() < input() :: boolean()
  def a < b do
    a = to_decimal(a)
    b = to_decimal(b)

    Decimal.lt?(a, b)
  end

  @doc """
  Whether a number is less than or equal to the other or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> "41" <= "42"
      true
      iex> 41 <= 42
      true
      iex> 41.0 <= 42.0
      true
      iex> 41.0 <= "42.0"
      true
      iex> 42 <= 42
      true
      iex> 42 <= 41
      false
  """
  @spec input() <= input() :: boolean()
  def a <= b do
    a = to_decimal(a)
    b = to_decimal(b)

    a < b or a == b
  end

  @doc """
  Whether the `number` is infinite or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> inf?(inf())
      true
      iex> inf?(-inf())
      true
  """
  @spec inf?(input()) :: boolean()
  def inf?(number) do
    number = to_decimal(number)

    Decimal.inf?(number)
  end

  @doc """
  Whether the value is a `number` or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> number?(42)
      true
      iex> number?("42.0")
      true
      iex> number?(42.0)
      true
      iex> number?("+Inf")
      true
      iex> number?("-Inf")
      true
      iex> number?(%Decimal{coef: :NaN})
      false
  """
  @spec number?(input()) :: boolean()
  def number?(number) do
    number = to_decimal(number)

    not Decimal.nan?(number)
  end

  @doc """
  Whether the `number` is an integer or not.

  ## Examples

      iex> use DecimalEnv.Operators
      iex> integer?(42)
      true
      iex> integer?("42")
      true
      iex> integer?(42.0)
      true
      iex> integer?(42.5)
      false
      iex> integer?("42.5")
      false
  """
  @spec integer?(input()) :: boolean()
  def integer?(number) do
    number = to_decimal(number)

    Decimal.integer?(number)
  end

  #########
  # Helpers

  @spec to_decimal(input()) :: Decimal.t() | no_return()
  defp to_decimal(value)

  defp to_decimal(%Decimal{} = value) do
    value
  end

  defp to_decimal(value) when is_float(value) do
    Decimal.from_float(value)
  end

  defp to_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {result, ""} ->
        result

      _ ->
        raise ArgumentError, message: "#{value} is not a valid numeric value"
    end
  end

  defp to_decimal(value) when is_integer(value) do
    Decimal.new(value)
  end
end
