defmodule Ivy.Package do
  alias Ivy.{Constraint, Logical, LSubst, LVar, Unifyable}

  @behaviour Access

  defstruct [s: %{}, d: %{}, c: [], vs: nil, oc: true, meta: %{}]
  @type t :: %__MODULE__{
    s: %{LVar.t => LSubst.t | LVar.t},
    d: %{LVar.t => Domain.t},
    c: [Constraint.t],
    vs: [LVar.t] | nil,
    oc: boolean,
    meta: map()
  }

  def new() do
    %__MODULE__{}
  end

  @impl Access
  def fetch(package, key) do
    Map.fetch(package, key)
  end

  @impl Access
  def pop(package, key) do
    Map.pop(package, key)
  end

  @impl Access
  def get_and_update(package, key, fun) do
    Map.get_and_update(package, key, fun)
  end

  def ext(s, u, v) do
    vv = if match?(%LSubst{}, v), do: v.v, else: v
    if s.oc and occurs?(s, u, vv) do
      nil
    else
      ext_no_check(s, u, v)
    end
  end

  def ext_no_check(s, u, v) do
    put_in(s, [:s, u], v)
    |> Map.update(:vs, nil, fn
      vs when is_list(vs) -> [u | vs]
      vs -> vs
    end)
  end

  def unify(s, u, u), do: s
  def unify(s, u, v) do
    case {walk(s, u), walk(s, v)} do
      {%LVar{} = u, u} -> s
      {%LVar{} = u, v} -> Unifyable.unify(u, v, s)
      {u, %LVar{} = v} -> Unifyable.unify(v, u, s)
      {u, v} -> Unifyable.unify(u, v, s)
    end
  end

  def walk(%__MODULE__{s: s}, %LVar{} = v),
    do: walk_impl(v, Map.get(s, v), s)
  def walk(_, v), do: v

  defp walk_impl(lv, nil, _), do: lv
  defp walk_impl(_, %LSubst{v: sv}, _), do: sv
  defp walk_impl(_, %LVar{} = vp, s) do
    walk_impl(vp, Map.get(s, vp), s)
  end
  defp walk_impl(_, vp, _), do: vp

  def reify(s, v) do
    Logical.reify(walk(s, v), s)
  end

  def occurs?(s, u, v) do
    Logical.occurs?(walk(s, v), u, s)
  end

  def build(s, u) do
    Logical.build(u, s)
  end

  defimpl Ivy.Bindable do
    def bind(a, g) do
      g.(a)
    end

    def mplus(a, f) do
      %Ivy.Choice{a: a, f: f}
    end

    def take(a) do
      a
    end
  end

  defimpl Ivy.IfA do
    alias Ivy.Bindable

    def ifa(%@for{s: s} = b, gs, _) do
      %{b | s: Enum.reduce(gs, s, &Bindable.bind(&2, &1))}
    end
  end

  defimpl Ivy.IfU do
    alias Ivy.Bindable

    def ifu(%@for{s: s} = b, gs, _) do
      %{b | s: Enum.reduce(gs, s, &Bindable.bind(&2, &1))}
    end
  end
end
