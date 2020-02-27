defmodule Ivy.Utils do
  alias Ivy.{Package, Walkable}

  def empty_fun(), do: fn -> nil end
  def succeed(a), do: a
  def fail(_a), do: nil

  def reify(s, v) do
    v = walk(s, v)
    walk(Package.reify(Package.new(), v), v)
  end

  def reify(s, v, r) do
    v = walk(s, v)
    walk(Package.reify(r, v), v)
  end

  def walk(s, v) do
    Walkable.walk(
      Package.walk(s, v),
      fn x ->
        case Package.walk(s, x) do
          x when is_list(x) -> walk(s, x)
          x -> x
        end
      end
    )
  end

  def do_blockifier(do: {:__block__, _, xs}), do: xs
  def do_blockifier(do: x), do: [x]
  def do_blockifier(xs), do: xs
end
