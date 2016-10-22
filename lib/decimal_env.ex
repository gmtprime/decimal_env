defmodule DecimalEnv do
  @moduledoc """
  This module provides two macros to be able to use `Decimal`s with regular
  Elixir operators i.e.

      iex> import DecimalEnv
      iex> decimal do
      ...>   21.0 + "21.0"
      ...> end
      #Decimal<42.0>

  It is possible to provide a decimal context as argument for the macro i.e

      iex> import DecimalEnv
      iex> decimal context: [precision: 2] do
      ...>   1 / 3
      ...> end
      #Decimal<0.33>

  > For more information about context check `Decimal.Context` struct in
  > `Decimal` repository.

  Not all the Elixir statements are valid. The purpose of these macros is to
  make it easier to write formulas involving `Decimal` type, so writing Elixir
  code inside the `decimal` block is discouraged i.e:

      iex> import DecimalEnv
      iex> Enum.reduce([10.99, 10.01, 20.99, 0.01], 0.00,
      ...>   fn x, acc ->
      ...>     decimal do: x + acc
      ...>   end)
      #Decimal<42.00>

  The previous example calculates the sum of a list of `Float`s, but returns
  the result as a `Decimal` type. The code is more clear than its equivalent
  without the macro:

      iex> Enum.reduce([10.99, 10.01, 20.99, 0.01], Decimal.new(0.00),
      ...>   fn x, %Decimal{} = acc ->
      ...>     Decimal.add(Decimal.new(x), acc)
      ...>   end)
      #Decimal<42.00>

  The only statement offered is `if` statement i.e:

      iex> import DecimalEnv
      iex> a = 42.0
      iex> decimal do
      ...>   if a > 10, do: a, else: 10
      ...> end
      #Decimal<42.0>

  > The guard in the `if` statement should be a decimal comparison.

  It is posible to assign variables inside the block, but pattern matching is
  not available i.e:

      iex> import DecimalEnv
      iex> decimal context: [precision: 2] do
      ...>   a = div(42.1, 2.0)
      ...>   a * 2
      ...> end
      #Decimal<42>

  > Constant values inside the decimal block are precalculated at compile time.

  To avoid calculating the `Decimal` value every time a variable external to
  the block is mentioned inside the block, use the `:bind` i.e:

      iex> import DecimalEnv
      iex> a = 3
      iex> x = 4
      iex> decimal bind: [a: a] do
      ...>   a * (x + 1 + a * a)
      ...> end
      #Decimal<42>

  In the previous example, the variable `a` is converted to `Decimal` only one
  time instead of three times. The variable `x` only appears one time, so there
  is no need to add it to the bind `Keyword` list.

  Additionally you can change the name of the external variable by changing the
  name of the key associated with it i.e:

      iex> import DecimalEnv
      iex> a = 3
      iex> x = 4
      iex> decimal bind: [b: a] do
      ...>   b * (x + 1 + b * b)
      ...> end
      #Decimal<42>

  In the previous example, the external variable `a` is renamed to `b` inside
  the decimal block.
  """

  @doc """
  This macro receives a list of `options` and a do `block` (`list` argument).
  The `options` available are:
  
    * `context`: Keyword list containing the context definition. The keys have
    the same name as the ones in the `Decimal.Context` struct.
    * `bind`: Keyword list that indicates which external variables should be
    converted to `Decimal` right away before the block is executed.

  ## Example

      iex> import DecimalEnv
      iex> decimal context: [precision: 2] do
      ...>   21.0 * 2
      ...> end
      #Decimal<42>
  """
  defmacro decimal(options, do: block) do
    bound = bind_decimal(options[:bind])
    context = generate_context(options[:context])
    block =
      case expand(block) do
        {:__block__, _, stmts} ->
          {:__block__, [], bound ++ stmts}
        other ->
          {:__block__, [], bound ++ [other]}
      end
    quote do
      Decimal.with_context(unquote(context), fn ->
        unquote(block)
      end)
    end
  end

  @doc """
  This macro receives a decimal do `block` (`list` argument). The global
  `Decimal` context is used to do the operations inside the `block`.

  ## Example

      iex> import DecimalEnv
      iex> decimal do: 21.0 * 2
      #Decimal<42.0>
  """
  defmacro decimal(do: block) do
    block = expand(block)
    quote do: (fn -> unquote(block) end).()
  end

  ##
  # Expands the code to include the Decimal funcions instead.
  defp expand(str) when is_binary(str) do
    str |> parse() |> precalculated()
  end
  defp expand(number) when is_number(number) do
    number |> Decimal.new() |> precalculated()
  end
  defp expand(atom) when is_atom(atom) do
    atom
  end
  defp expand({:__block__, context, stmts}) do
    stmts = Enum.map(stmts, &expand/1)
    quote do: unquote({:__block__, context, stmts})
  end
  defp expand({:+, _, [num]}) do
    num = expand(num)
    quote do: Decimal.plus(unquote(num))
  end
  defp expand({:+, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.add(unquote(lhs), unquote(rhs))
  end
  defp expand({:-, _, [num]}) do
    num = expand(num)
    quote do: Decimal.minus(unquote(num))
  end
  defp expand({:-, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.sub(unquote(lhs), unquote(rhs))
  end
  defp expand({:*, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.mult(unquote(lhs), unquote(rhs))
  end
  defp expand({:/, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.div(unquote(lhs), unquote(rhs))
  end
  defp expand({:>, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.cmp(unquote(lhs), unquote(rhs)) == :gt
  end
  defp expand({:<, context, [lhs, rhs]}) do
    expand({:>, context, [rhs, lhs]})
  end
  defp expand({:==, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.cmp(unquote(lhs), unquote(rhs)) == :eq
  end
  defp expand({:>=, context, args}) do
    gt = expand({:>, context, args})
    eq = expand({:==, context, args})
    quote do: unquote(gt) or unquote(eq)
  end
  defp expand({:<=, context, args}) do
    lt = expand({:<, context, args})
    eq = expand({:==, context, args})
    quote do: unquote(lt) or unquote(eq)
  end
  defp expand({:!=, context, args}) do
    eq = expand({:==, context, args})
    quote do: not unquote(eq)
  end
  defp expand({:abs, _, [num]}) do
    num = expand(num)
    quote do: Decimal.abs(unquote(num))
  end
  defp expand({:inf?, _, [num]}) do
    num = expand(num)
    quote do: Decimal.inf?(unquote(num))
  end
  defp expand({:max, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.max(unquote(lhs), unquote(rhs))
  end
  defp expand({:min, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.min(unquote(lhs), unquote(rhs))
  end
  defp expand({:nan?, _, [num]}) do
    num = expand(num)
    quote do: Decimal.nan?(unquote(num))
  end
  defp expand({:div, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.div_int(unquote(lhs), unquote(rhs))
  end
  defp expand({:reduce, _, [num]}) do
    num = expand(num)
    quote do: Decimal.reduce(unquote(num))
  end
  defp expand({:rem, _, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    quote do: Decimal.rem(unquote(lhs), unquote(rhs))
  end
  defp expand({:round, _, [num | rest]}) do
    num = expand(num)
    quote do: apply(Decimal, :round, [unquote(num) | unquote(rest)])
  end
  defp expand({:{}, context, members}) do
    members = Enum.map(members, &expand/1)
    quote do: unquote({:{}, context, members})
  end
  defp expand(xs) when is_list(xs) do
    xs = Enum.map(xs, &expand/1)
    quote do: unquote(xs)
  end
  defp expand({fst, snd}) do
    fst = expand(fst)
    snd = expand(snd)
    quote do: {unquote(fst), unquote(snd)}
  end
  defp expand({:=, context, [lhs, rhs]}) do
    lhs = expand_lhs(lhs)
    rhs = expand(rhs)
    bind = {:=, context, [lhs, rhs]}
    quote do: unquote(bind)
  end
  defp expand({:if, context, [guard, [do: is_true, else: is_false]]}) do
    guard = expand(guard)
    is_true = expand(is_true)
    is_false = expand(is_false)
    if_stmt = {:if, context, [guard, [do: is_true, else: is_false]]}
    quote do: unquote(if_stmt)
  end
  defp expand({:and, context, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    and_op = {:and, context, [lhs, rhs]}
    quote do: unquote(and_op)
  end
  defp expand({:or, context, [lhs, rhs]}) do
    lhs = expand(lhs)
    rhs = expand(rhs)
    or_op = {:or, context, [lhs, rhs]}
    quote do: unquote(or_op)
  end
  defp expand({name, _, _} = var) when is_atom(name) or is_tuple(name) do
    quote do: apply(DecimalEnv, :expand_rt, [unquote(var)])
  end

  ##
  # Expands a variable on the left. Pattern matching is not allowed inside the
  # block.
  defp expand_lhs({name, _, _} = var) when is_atom(name), do: var

  @doc false
  # Expands variables at runtime.
  def expand_rt(var) when is_binary(var), do: var |> parse
  def expand_rt(var) when is_number(var), do: var |> Decimal.new()
  def expand_rt(var) when is_tuple(var) do
    var
    |> Tuple.to_list()
    |> Enum.map(&expand_rt/1)
    |> List.to_tuple()
  end
  def expand_rt(var) when is_list(var) do
    var
    |> Enum.map(&expand_rt/1)
  end
  def expand_rt(var), do: var

  ##
  # Parses a string to Decimal.
  defp parse(str) when is_binary(str) do
    case Decimal.parse(str) do
      :error -> str
      {:ok, parsed} -> parsed
    end
  end

  ##
  # Returns a Decimal calculated at compile time.
  defp precalculated(%Decimal{coef: coef, exp: exp, sign: sign}) do
    quote do
      %Decimal{coef: unquote(coef), exp: unquote(exp), sign: unquote(sign)}
    end
  end
  defp precalculated(other), do: other

  ##
  # Generates context depending on a list of options.
  defp generate_context(nil) do
    generate_context([])
  end
  defp generate_context([]) do
    quote do
      Decimal.get_context()
    end
  end
  defp generate_context(context) do
    context =
      Decimal.get_context()
       |> Map.from_struct()
       |> Enum.map(fn {key, value} ->
            {key, Keyword.get(context, key, value)}
          end)
    quote do
      %Decimal.Context{
        flags: unquote(context[:flags]),
        precision: unquote(context[:precision]),
        rounding: unquote(context[:rounding]),
        traps: unquote(context[:traps])
      }
    end
  end

  ##
  # Expands variables bound to the block.
  defp bind_decimal(nil) do
    []
  end
  defp bind_decimal(list) when is_list(list) do
    Enum.map(list, fn {k, v} ->
      name = Macro.var(k, nil)
      quote do: unquote(name) = DecimalEnv.expand_rt(unquote(v))
    end)
  end
end
