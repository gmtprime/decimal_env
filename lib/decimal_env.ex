defmodule DecimalEnv do
  @moduledoc """
  """

  @doc """
  """
  defmacro decimal(context, do: block) do
    context = generate_context(context)
    block = expand(block)
    quote do
      Decimal.with_context(unquote(context), fn ->
        unquote(block)
      end)
    end
  end

  @doc """
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
  defp expand(list) when is_list(list) do
    list = Enum.map(list, &expand/1)
    quote do: unquote(list)
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
  defp expand({:if, context, [condition, [do: is_true, else: is_false]]}) do
    condition = expand(condition)
    is_true = expand(is_true)
    is_false = expand(is_false)
    if_stmt = {:if, context, [condition, [do: is_true, else: is_false]]}
    quote do: unquote(if_stmt)
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
end
