# DecimalEnv

![Build status](https://github.com/gmtprime/decimal_env/actions/workflows/checks.yml/badge.svg) [![Hex pm](http://img.shields.io/hexpm/v/decimal_env.svg?style=flat)](https://hex.pm/packages/decimal_env) [![hex.pm downloads](https://img.shields.io/hexpm/dt/decimal_env.svg?style=flat)](https://hex.pm/packages/decimal_env)

> **Environment** (_noun_): The totality of the natural world, often excluding
> humans.

This library provides a macro to encapsulate `Decimal` operations while using
Elixir operators e.g:

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal do
...(2)>   21.0 + "21.0"
...(2)> end
#Decimal<42.0>
```

> For more information on `Decimal` library, you can go to
> [its documentation](https://hexdocs.pm/decimal/readme.html).

There are two options we can provide to control the operations happening inside
the `decimal` block:

- `:context` - `Decimal.Context` struct. it can also be a `keyword` list. Check
  [its documentation](https://hexdocs.pm/decimal/Decimal.Context.html#content)
  for more information.
- `:as` - In which type we should have the result. The possible values are
  the following:
  + `:decimal` (default)
  + `:float`
  + `:integer`
  + `:string`
  + `:xsd`
  + `:raw`
  + `:scientific`

The following would be a more complex example for the macro:

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal context: [precision: 2, rounding: :ceiling], as: :integer do
...(2)>   21.1 + 20
...(2)> end
42
```

The macro overloads all Elixir numeric operators and that's why the block can
contain any valid Elixir code e.g. the following snippet calculates the mean
of the numbers `1`, `2`, `3` and `4` which is `2.5`:

```elixir
iex(1)> import DecimalEnv
iex(2)> decimal as: :float do
...(2)>   values = [1,2,3,4]
...(2)>   amount = length(values)
...(2)>
...(2)>   Enum.reduce(values, 0, &(&1 + &2)) / amount
...(2)> end
2.5
```

## Installation

Add it to your `mix.exs`

```elixir
def deps do
  [{:decimal_env, "~> 1.0"}]
end
```

## Author

Alexander de Sousa.

## License

`DecimalEnv` is released under the MIT License. See the LICENSE file for
further details.
