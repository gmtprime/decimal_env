defmodule DecimalEnvTest do
  use ExUnit.Case, async: true
  doctest DecimalEnv
  import DecimalEnv

  describe "decimal/1" do
    test "converts integer" do
      expected = Decimal.new("42")

      result = decimal(do: 42)

      assert Decimal.eq?(expected, result)
    end

    test "converts float" do
      expected = Decimal.new("42")

      result = decimal(do: 42.0)

      assert Decimal.eq?(expected, result)
    end

    test "converts string" do
      expected = Decimal.new("42")

      result = decimal(do: "42")

      assert Decimal.eq?(expected, result)
    end

    test "converts variable" do
      expected = Decimal.new("42")
      variable = "42.0"

      result = decimal(do: variable)

      assert Decimal.eq?(expected, result)
    end

    test "supports complex expression" do
      expected = Decimal.new("42")

      a = 1
      b = 2

      result =
        decimal do
          ("1" - a / b) * 100 + "-8"
        end

      assert Decimal.eq?(expected, result)
    end
  end

  describe "decimal/2" do
    test "converts to integer" do
      result =
        decimal as: :integer do
          42
        end

      assert 42 = result
    end

    test "converts to float" do
      result =
        decimal as: :float do
          42
        end

      assert 42.0 = result
    end

    test "converts to string" do
      result =
        decimal as: :string do
          -0.00000000042
        end

      assert "-0.00000000042" = result
    end

    test "converts to scientific" do
      result =
        decimal as: :scientific do
          "0.0000000042"
        end

      assert "4.2E-9" = result
    end

    test "converts to xsd format" do
      result =
        decimal as: :xsd do
          "4.2E-9"
        end

      assert "0.0000000042" = result
    end

    test "converts to raw format" do
      result =
        decimal as: :raw do
          "4.2E-9"
        end

      assert "42E-10" = result
    end

    test "modifies the context" do
      result =
        decimal context: [precision: 2, rounding: :ceiling], as: :string do
          21.1 + 20
        end

      assert "42" = result
    end
  end
end
