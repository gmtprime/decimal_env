defmodule DecimalEnvTest do
  use ExUnit.Case, async: true

  doctest DecimalEnv

  require DecimalEnv

  test "Expand numeric string" do
    result =
      DecimalEnv.decimal do
        "42.24"
      end
    expected = Decimal.new("42.24")
    assert expected == result
  end

  test "Expand non-numeric string" do
    result =
      DecimalEnv.decimal do
        "don't panic!"
      end
    assert "don't panic!" == result
  end

  test "Expand number" do
    result =
      DecimalEnv.decimal do
        42.24
      end
    expected = Decimal.new(42.24)
    assert expected == result
  end

  test "Expand atom" do
    result =
      DecimalEnv.decimal do
        :atom
      end
    assert :atom == result
  end

  test "Expand unary plus" do
    result =
      DecimalEnv.decimal do
        +42.24
      end
    expected = 42.24 |> Decimal.new() |> Decimal.plus()
    assert expected == result
  end

  test "Expand binary addition" do
    result =
      DecimalEnv.decimal do
        42.0 + 0.24
      end
    expected = Decimal.add(Decimal.new(42.0), Decimal.new(0.24))
    assert expected == result
  end

  test "Expand unary minus" do
    result =
      DecimalEnv.decimal do
        -42.24
      end
    expected = 42.24 |> Decimal.new() |> Decimal.minus()
    assert expected == result
  end

  test "Expand binary substraction" do
    result =
      DecimalEnv.decimal do
        42.0 - 0.24
      end
    expected = Decimal.sub(Decimal.new(42.0), Decimal.new(0.24))
    assert expected == result
  end

  test "Expand binary multiplication" do
    result =
      DecimalEnv.decimal do
        21.0 * 2.0
      end
    expected = Decimal.mult(Decimal.new(21.0), Decimal.new(2.0))
    assert expected == result
  end

  test "Expand binary division" do
    result =
      DecimalEnv.decimal do
        43.0 / 2.0
      end
    expected = Decimal.div(Decimal.new(43.0), Decimal.new(2.0))
    assert expected == result
  end

  test "Expand bind operator and block" do
    result =
      DecimalEnv.decimal do
        c = 21.0 * 2
        c / 2.0
      end
    expected =
      Decimal.div(
        Decimal.mult(Decimal.new(21.0), Decimal.new(2)), Decimal.new(2.0))
    assert expected == result
  end

  test "Expand greater than" do
    result =
      DecimalEnv.decimal do
        42.0 > 41.0
      end
    expected = Decimal.cmp(Decimal.new(42.0), Decimal.new(41.0)) == :gt
    assert expected == result
  end

  test "Expand less than" do
    result =
      DecimalEnv.decimal do
        41.0 < 42.0
      end
    expected = Decimal.cmp(Decimal.new(41.0), Decimal.new(42.0)) == :lt
    assert expected == result
  end

  test "Expand equals to" do
    result =
      DecimalEnv.decimal do
        42.0 == 42.0
      end
    expected = Decimal.cmp(Decimal.new(42.0), Decimal.new(42.0)) == :eq
    assert expected == result
  end

  test "Expand greater than or equals to" do
    result =
      DecimalEnv.decimal do
        42.1 >= 42.0
      end
    expected =
      Decimal.cmp(Decimal.new(42.1), Decimal.new(42.0)) == :gt or
      Decimal.cmp(Decimal.new(42.1), Decimal.new(42.0)) == :eq  
    assert expected == result
  end

  test "Expand less than or equals to" do
    result =
      DecimalEnv.decimal do
        42.0 <= 42.1
      end
    expected =
      Decimal.cmp(Decimal.new(42.0), Decimal.new(42.1)) == :lt or
      Decimal.cmp(Decimal.new(42.0), Decimal.new(42.1)) == :eq  
    assert expected == result
  end

  test "Expand different to" do
    result =
      DecimalEnv.decimal do
        42.1 != 42.0
      end
    expected = Decimal.cmp(Decimal.new(42.1), Decimal.new(42.0)) != :eq
    assert expected == result
  end

  test "Expand abs" do
    result =
      DecimalEnv.decimal do
        abs(-42.24)
      end
    expected = 42.24 |> Decimal.new() |> Decimal.minus() |> Decimal.abs()
    assert expected == result
  end

  test "Expand inf?" do
    result =
      DecimalEnv.decimal do
        inf?("inf")
      end
    expected = "inf" |> Decimal.new() |> Decimal.inf?()
    assert expected == result
  end

  test "Expand max" do
    result =
      DecimalEnv.decimal do
        max(42.1, 42.0)
      end
    expected = Decimal.max(Decimal.new(42.1), Decimal.new(42.0))
    assert expected == result
  end

  test "Expand min" do
    result =
      DecimalEnv.decimal do
        min(42.1, 42.0)
      end
    expected = Decimal.min(Decimal.new(42.1), Decimal.new(42.0))
    assert expected == result
  end

  test "Expand nan?" do
    result =
      DecimalEnv.decimal do
        nan?("nan")
      end
    expected = "nan" |> Decimal.new() |> Decimal.nan?()
    assert expected == result
  end

  test "Expand integer division" do
    result =
      DecimalEnv.decimal do
        div(42.1, 2.0)
      end
    expected = Decimal.div_int(Decimal.new(42.1), Decimal.new(2.0))
    assert expected == result
  end

  test "Expand reduce" do
    result =
      DecimalEnv.decimal do
        reduce(100.0)
      end
    expected = 100.0 |> Decimal.new() |> Decimal.reduce()
    assert expected == result
  end

  test "Expand rem" do
    result =
      DecimalEnv.decimal do
        rem(42.1, 2.0)
      end
    expected = Decimal.rem(Decimal.new(42.1), Decimal.new(2.0))
    assert expected == result
  end

  test "Expand round" do
    result =
      DecimalEnv.decimal do
        round(42.9)
      end
    expected = 42.9 |> Decimal.new() |> Decimal.round()
    assert expected == result
  end

  test "Expand tuple > 3 members" do
    result =
      DecimalEnv.decimal do
        {1, 2, 3}
      end
    expected = {Decimal.new(1), Decimal.new(2), Decimal.new(3)}
    assert expected == result
  end

  test "Expand list" do
    result =
      DecimalEnv.decimal do
        [1, 2, 3]
      end
    expected = [1, 2, 3] |> Enum.map(&Decimal.new/1)
    assert expected == result
  end

  test "Expand tuple < 3 members" do
    result =
      DecimalEnv.decimal do
        {1, 2}
      end
    expected = {Decimal.new(1), Decimal.new(2)}
    assert expected == result
  end

  test "Expand if statement" do
    result =
      DecimalEnv.decimal do
        if 42.0 > 41.0, do: {:ok, 42.0}, else: {:error, 41.0}
      end
    assert {:ok, Decimal.new(42.0)} == result
  end

  test "Expand binary and" do
    result =
      DecimalEnv.decimal do
        42.0 < 41.0 and true
      end
    assert result == false
  end

  test "Expand binary or" do
    result =
      DecimalEnv.decimal do
        42.0 < 41.0 or true
      end
    assert result == true
  end

  test "Expand binary at runtime" do
    number = "42.0"
    result =
      DecimalEnv.decimal do
        number
      end
    expected = Decimal.new("42.0")
    assert expected == result
  end

  test "Expand number at runtime" do
    number = 42.0
    result =
      DecimalEnv.decimal do
        number
      end
    expected = Decimal.new(number)
    assert expected == result
  end

  test "Expand tuple at runtime" do
    tuple = {1, 2, 3}
    result =
      DecimalEnv.decimal do
        tuple
      end
    expected = {Decimal.new(1), Decimal.new(2), Decimal.new(3)}
    assert expected == result
  end

  test "Expand list at runtime" do
    list = [1, 2, 3]
    result =
      DecimalEnv.decimal do
        list
      end
    expected = Enum.map(list, &Decimal.new/1)
    assert expected == result
  end

  test "Expand atom at runtime" do
    atom = :atom
    result =
      DecimalEnv.decimal do
        atom
      end
    assert atom == result
  end

  test "Expand Decimal at runtime" do
    decimal = Decimal.new(42.0)
    result =
      DecimalEnv.decimal do
        decimal
      end
    assert decimal == result
  end

  test "Decimal with context" do
    result =
      DecimalEnv.decimal [precision: 1] do
        42.0
      end
    expected =
      Decimal.with_context(
        %Decimal.Context{Decimal.get_context() | precision: 1},
        fn -> Decimal.new(42.0) end
      )
    assert expected == result
  end
end
