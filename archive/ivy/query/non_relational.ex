defmodule Ivy.NonRelational do
  defmacro project(vars, goals) do
    a = Macro.var(:a, nil)
    bindings = Enum.map(vars, fn var ->
      quote do
        unquote(var) = Ivy.Utils.walk(unquote(a), unquote(var))
      end
    end)

    quote do
      fn unquote(a) ->
        unquote_splicing(bindings)
        fresh([], unquote(goals)).(unquote(a))
      end
    end
  end

  defmacro pred(v, f) do
    quote do
      project [unquote(v)] do
        unify(unquote(f).(unquote(v)), true)
      end
    end
  end

  defmacro is(u, v, op \\ fn x -> x end) do
    quote do
      project [unquote(v)] do
        unify(unquote(u), unquote(op).(unquote(v)))
      end
    end
  end
end
