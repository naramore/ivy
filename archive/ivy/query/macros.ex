defmodule Ivy.Macros do
  alias Ivy.Utils

  defmacro ifa([[e | gs] | t]) when is_list(t) do
    quote do
      Ivy.IfA.ifa(unquote(e), unquote(gs), ifa(unquote(t)))
    end
  end
  defmacro ifa(_), do: nil

  defmacro ifu([[e | gs] | t]) when is_list(t) do
    quote do
      Ivy.IfU.ifu(unquote(e), unquote(gs), ifu(unquote(t)))
    end
  end
  defmacro ifu(_), do: nil

  defmacro all(goals) do
    case Utils.do_blockifier(goals) do
      [] ->
        quote do
          &Ivy.succeed/1
        end
      goals ->
        quote do
          fn a ->
            bind(a, unquote(goals))
          end
        end
    end
  end

  defmacro bind(a, gs) do
    case Utils.do_blockifier(gs) do
      [g] ->
        quote do
          Ivy.Bindable.bind(unquote(a), unquote(g))
        end
      [g | gs] ->
        quote do
          bind(Ivy.Bindable.bind(unquote(a), unquote(g)), unquote(gs))
        end
    end
  end

  defmacro mplus(es) do
    case Utils.do_blockifier(es) do
      [e] ->
        quote do
          unquote(e)
        end
      [e | es] ->
        quote do
          Ivy.Bindable.mplus(unquote(e), fn -> mplus(unquote(es)) end)
        end
    end
  end

  defmacro inc(do: block) do
    quote do
      fn -> unquote(block) end
    end
  end
  defmacro inc(expression) do
    quote do
      fn -> unquote(expression) end
    end
  end
end
