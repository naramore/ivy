defmodule Ivy.Debug do
  defmacro log(message, level \\ :info, metadata \\ []) do
    quote do
      fn a ->
        _ = Logger.log(
          unquote(level),
          fn -> unquote(message) end,
          unquote(metadata)
        )
        a
      end
    end
  end

  defmacro puts(s) do
    quote do
      fn a ->
        _ = IO.puts(unquote(s))
        a
      end
    end
  end

  defmacro trace_package() do
    quote do
      fn a ->
        _ = IO.inspect(a)
        a
      end
    end
  end

  defmacro trace_lvars(title, lvars \\ []) do
    a = Macro.var(:a, nil)
    quote do
      fn unquote(a) ->
        _ = IO.puts(unquote(title))
        _ = Enum.each(unquote(lvars), fn lvar ->
          IO.puts("#{String.pad_leading(to_string(lvar.name), 5)} = #{inspect(Ivy.Utils.reify(unquote(a), lvar))}")
        end)
        unquote(a)
      end
    end
  end
end
