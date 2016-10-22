# DecimalEnv

[![Build Status](https://travis-ci.org/gmtprime/decimal_env.svg?branch=master)](https://travis-ci.org/gmtprime/decimal_env) [![Hex pm](http://img.shields.io/hexpm/v/decimal_env.svg?style=flat)](https://hex.pm/packages/decimal_env) [![hex.pm downloads](https://img.shields.io/hexpm/dt/decimal_env.svg?style=flat)](https://hex.pm/packages/decimal_env) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/gmtprime/decimal_env.svg)](https://beta.hexfaktor.org/github/gmtprime/decimal_env) [![Inline docs](http://inch-ci.org/github/gmtprime/decimal_env.svg?branch=master)](http://inch-ci.org/github/gmtprime/decimal_env)

This library provides two macros to be able to use `Decimal`s with regular
Elixir operators i.e.

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal do
...(2)>   21.0 + "21.0"
...(2)> end
#Decimal<42.0>
```

It is possible to provide a decimal context as argument for the macro i.e

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal [precision: 2] do
...(2)>   1 / 3
...(2)> end
#Decimal<0.33>
```

> For more information about context check `Decimal.Context` struct in
> `Decimal` repository.

Not all the Elixir statements are valid. The purpose of these macros is to
make it easier to write formulas involving `Decimal` type, so writing Elixir
code inside the `decimal` block is discouraged i.e.

```elixir
iex(1)> import DecimalEnv
iex(2)> Enum.reduce([10.99, 10.01, 20.99, 0.01], 0.00,
...(2)>   fn x, acc ->
...(2)>     decimal do: x + acc
...(2)>   end)
#Decimal<42.00>
```

The previous example calculates the sum of a list of `Float`s, but returns
the result as a `Decimal` type. The code is more clear than its equivalent
without the macro:

```elixir
iex(1)> Enum.reduce([10.99, 10.01, 20.99, 0.01], Decimal.new(0.00),
...(2)>   fn x, %Decimal{} = acc ->
...(2)>     Decimal.add(Decimal.new(x), acc)
...(2)>   end)
#Decimal<42.00>
```

The only statement offered is `if` statement i.e:

```elixir
iex(1)> import DecimalEnv
iex(1)> a = 42.0
iex(3)> decimal do
...(3)>   if a > 10, do: a, else: 10
...(3)> end
#Decimal<42.0>
```

> The guard in the `if` statement should be a decimal comparison.

It is posible to assign variables inside the block, but pattern matching is
not available i.e:

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal [precision: 2] do
...(2)>   a = div(42.1, 2.0)
...(2)>   a * 2
...(2)> end
#Decimal<42>
```

> Constant values inside the decimal block are precalculated at compile time.

To avoid calculating the `Decimal` value every time a variable external to
the block is mentioned inside the block, use the `:bind` option:

```elixir
iex> import DecimalEnv
iex> a = 3
iex> x = 4
iex> decimal bind: [a: a] do
...>   a * (x + 1 + a * a)
...> end
#Decimal<42>
```

In the previous example, the variable `a` is converted to `Decimal` only one
time instead of three times. The variable `x` only appears one time, so there
is no need to add it to the bind `Keyword` list.

Additionally you can change the name of the external variable by changing the
name of the key associated with it i.e:

```elixir
iex> import DecimalEnv
iex> a = 3
iex> x = 4
iex> decimal bind: [b: a] do
...>   b * (x + 1 + b * b)
...> end
#Decimal<42>
```

In the previous example, the external variable `a` is renamed to `b` inside
the decimal block.

## Installation

Add it to your `mix.exs`

```elixir
def deps do
  [{:decimal_env, "~> 0.2"}]
end
```

## Author

Alexander de Sousa.

## License

`DecimalEnv` is released under the MIT License. See the LICENSE file for
further details.
