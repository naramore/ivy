defmodule Ivy.Examples.Lambda do
  use Ivy

  defna find(x, [[y, :-, o] | _], o) do
    project [x, y] do
      unify(x == y, true)
    end
  end
  defna find(x, [_ | c], o), do: find(x, c, o)

  def typed(c, x, t) do
    conda do
      [lvar(x), find(x, c, t)]
      matche [c, x, t] do
        [_, [[y], :>>, a], [s, :>, t]] ->
          fresh [l] do
            cons([y, :-, s], c, l)
            typed(l, a, t)
          end
        [_, [:apply, a, b], _] ->
          fresh [s] do
            typed(c, a, [s, :>, t])
            typed(c, b, s)
          end
      end
    end
  end

  def execute(1) do
    run * [q] do
      fresh [f, g, a, b, t] do
        typed([[f :- a], [g, :-,b]], [:apply, f, g], t)
        unify(q, a)
      end
    end
  end
  def execute(2) do
    run * [q] do
      fresh [f, g, a, t] do
        typed([[f, :-, a], [g, :-, :int]], [:apply, f, g], t)
        unify(q, a)
      end
    end
  end
  def execute(3) do
    run * [q] do
      fresh [f, g, a, t] do
        typed([[f, :-, [:int, :>, :float]], [g, :-, a]], [:apply, f, g], t)
        unify(q, a)
      end
    end
  end
  def execute(4) do
    run * [t] do
      fresh [f, a, b] do
        typed([f, :-, a], [:apply, f, f], t)
      end
    end
  end
  def execute(5) do
    run * [t] do
      fresh [x, y] do
        typed([], [[x], :>>, [[y], :>> [:apply, y, x]]], t)
      end
    end
  end

  @expected :: %{
    1 => [[:"_.0", :>, :"_.1"]],
    2 => [[:int, :>, :"_.0"]],
    3 => [:int],
    4 => [],
    5 => [[:"_.0", :>, [[:"_.0", :> :"_.1"], :>, :"_.1"]]],
  }

  def execute() do
    results =
      Enum.map(1..5, %{}, fn x, acc ->
        Map.put(acc, x, execute(x))
      end)

    %{
      expected: @expected,
      results: results
    }
  end
end
