defmodule Ivy.Choice do
  defstruct [:a, :f]
  @type t :: %__MODULE__{}

  def new(a, f) do
    %__MODULE__{a: a, f: f}
  end

  defimpl Ivy.Bindable do
    def bind(%@for{a: a, f: f}, g) do
      @protocol.mplus(g.(a), fn -> @protocol.bind(f, g) end)
    end

    def mplus(%@for{a: a, f: f}, fp) do
      %@for{a: a, f: fn -> @protocol.mplus(fp.(), f) end}
    end

    def take(%@for{a: a, f: f}) do
      Stream.concat([a], @protocol.take(f))
    end
  end

  defimpl Ivy.IfA do
    alias Ivy.Bindable

    def ifa(b, gs, _) do
      Enum.reduce(gs, b, &Bindable.bind(&2, &1))
    end
  end

  defimpl Ivy.IfU do
    alias Ivy.Bindable

    def ifu(%@for{a: a}, gs, _) do
      Enum.reduce(gs, a, &Bindable.bind(&2, &1))
    end
  end
end
