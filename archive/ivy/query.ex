# TODO: modify all macros to NOT be macros and expect lvars
# TODO: create a wrapper macro to recursively replace all
#       unbound variables with lvars

defmodule Ivy.Query do
  import Ivy.Macros
  import Ivy.NonRelational
  alias Ivy.{Bindable, Choice, Package, Utils}

  @type goal :: (Package.t -> Bindable.t)
  @type thunk :: (() -> Bindable.t)

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Ivy.Macros
      import Ivy.NonRelational
      import Ivy.Debug
      import Ivy
    end
  end

  def unify(u, v) do
    fn a ->
      Package.unify(a, u, v)
    end
  end

  defmacro conde(clauses \\ []) do
    a = Macro.var(:a, nil)
    quote do
      fn unquote(a) ->
        inc do
          mplus(unquote(bind_conde_clauses(a, clauses)))
        end
      end
    end
  end

  @doc false
  def bind_conde_clauses(a, clauses) do
    Enum.map(clauses, fn goals ->
      quote do
        bind(unquote(a), unquote(goals))
      end
    end)
  end

  def alt(goals \\ []) do
    fn a ->
      fn ->
        mplus_alt(
          Enum.map(goals, &Bindable.bind(a, &1))
        )
      end
    end
  end

  defp mplus_alt([e]), do: e
  defp mplus_alt([e | es]) do
    Bindable.mplus(e, fn -> mplus_alt(es) end)
  end

  defmacro fresh(bindings, goals) do
    goals = Utils.do_blockifier(goals)
    bound =
      Enum.map(bindings, fn {name, _, _} = form ->
        quote do
          unquote(form) = Ivy.LVar.new(unquote(name), unquote(Macro.escape(form)))
        end
      end)

    quote do
      fn a ->
        inc do
          unquote_splicing(bound)
          bind(a, unquote(goals))
        end
      end
    end
  end

  defmacro run(n, [binding], goals) do
    goals = Utils.do_blockifier(goals)
    quote do
      Enum.take(
        Ivy.Bindable.take(fn ->
          f = fresh unquote([binding]) do
            unquote_splicing(goals)
            reifyg(unquote(binding))
          end

          f.(Ivy.Package.new())
        end),
        unquote(n)
      )
    end
  end
  defmacro run(n, [_ | _] = bindings, goals) do
    goals = Utils.do_blockifier(goals)
    quote do
      run unquote(n), [q] do
        fresh unquote(bindings) do
          unify(q, unquote(bindings))
          unquote_splicing(goals)
        end
      end
    end
  end

  def also(goals \\ []) do
    fn a ->
      Enum.reduce(goals, a, &Bindable.bind(&2, &1))
    end
  end

  @doc false
  def reifyg(x) do
    all([
      fn a ->
        v = Utils.walk(a, x)
        case Package.reify(Package.new(), v) do
          %Package{s: s} when map_size(s) == 0 -> Choice.new(v, Utils.empty_fun())
          r -> Choice.new(Utils.walk(r, v), Utils.empty_fun())
        end
      end
    ])
  end

  defmacro conda(clauses) do
    a = Macro.var(:a, nil)
    clauses = Utils.do_blockifier(clauses)
    quote do
      fn unquote(a) ->
        Ivy.Macros.ifa(unquote(Enum.map(clauses, fn [g | gs] ->
          g.(a).(gs)
        end)))
      end
    end
  end

  defmacro condu(clauses) do
    a = Macro.var(:a, nil)
    clauses = Utils.do_blockifier(clauses)
    quote do
      fn unquote(a) ->
        Ivy.Macros.ifu(unquote(Enum.map(clauses, fn [g | gs] ->
          g.(a).(gs)
        end)))
      end
    end
  end

  def copy(u, v) do
    project [u] do
      Package.new()
      |> Package.build(u)
      |> Utils.walk(u)
      |> unify(v)
    end
  end

  defmacro lvar(v) do
    quote do
      fn a ->
        case Package.walk(a, unquote(v)) do
          %Ivy.LVar{} -> a
          _ -> nil
        end
      end
    end
  end

  defmacro non_lvar(v) do
    quote do
      fn a ->
        case Package.walk(a, unquote(v)) do
          %Ivy.LVar{} -> nil
          _ -> a
        end
      end
    end
  end

  def nil?(a), do: unify(nil, a)
  def empty(a), do: unify([], a)
  def cons(a, d, l), do: unify([a | d], l)
  def first(l, a), do: fresh([d], [cons(a, d, l)])
  def rest(l, d), do: fresh([a], [cons(a, d, l)])
  def every(g, coll) do
    fn a ->
      every_impl(g, Package.walk(a, coll)).(a)
    end
  end

  defp every_impl(_, []), do: &Utils.succeed/1
  defp every_impl(g, [h | t]) do
    all([
      g.(h),
      every_impl(g, t)
    ])
  end

  defmacro fne(_clauses) do
  end

  defmacro defne(_clauses) do
  end

  defmacro matche(_bindings, _clauses) do
  end

  defmacro fna(_clauses) do
  end

  defmacro fnu(_clauses) do
  end

  defmacro defna(_clauses) do
  end

  defmacro defnu(_clauses) do
  end

  defmacro matcha(_bindings, _clauses) do
  end

  defmacro matchu(_bindings, _clauses) do
  end

  #def disunify(u, v) do
  #  fn a ->
  #  end
  #end

  # defne member(x, [x | _])
  # defne member(x, [_ | t]), do: member?(x, t)

  # defne member1(x, [x | _])
  # defne member1(x, [h | t]) do
  #   disunify(x, h)
  #   member1(x, t)
  # end

  # defne append([], y, y)
  # defne append([a | d], y, [a | r]), do: append(d, y, r)

  # defne rember(x, [x | xs], xs)
  # defne rember(x, [y | ys], [y | zs]) do
  #   disunify(y, x)
  #   rember(x, ys, zs)
  # end

  # defne permute([], [])
  # defne permute([x | xs], yl) do
  #   fresh [ys] do
  #     permute(xs, ys)
  #     rember(x, yl, ys)
  #   end
  # end
end
