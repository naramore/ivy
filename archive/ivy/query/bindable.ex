defprotocol Ivy.Bindable do
  @fallback_to_any true

  @spec bind(t, Ivy.goal) :: t
  def bind(a, g)

  @spec mplus(t, Ivy.thunk) :: t
  def mplus(a, f)

  @spec take(t) :: Enumerable.t
  def take(a)
end

defimpl Ivy.Bindable, for: Stream do
  def bind(a, g) do
    Stream.map(a, &@protocol.bind(&1, g))
  end

  def mplus(a, f) do
    Stream.map(a, &@protocol.mplus(&1, f))
  end

  def take(a) do
    Stream.map(a, &@protocol.take/1)
  end
end

defimpl Ivy.Bindable, for: List do
  def bind(a, g) do
    Enum.map(a, &@protocol.bind(&1, g))
  end

  def mplus(a, f) do
    Enum.map(a, &@protocol.mplus(&1, f))
  end

  def take(a) do
    Enum.map(a, &@protocol.take/1)
  end
end

defimpl Ivy.Bindable, for: Function do
  import Ivy.Macros, only: [inc: 1]

  def bind(a, g) do
    inc(@protocol.bind(a.(), g))
  end

  def mplus(a, f) do
    inc(@protocol.mplus(f.(), a))
  end

  def take(a) do
    @protocol.take(a.())
  end
end

defimpl Ivy.Bindable, for: Any do
  alias Ivy.Choice

  def bind(nil, _g), do: nil
  def bind(a, _g), do: a

  def mplus(nil, f), do: f.()
  def mplus(a, f), do: %Choice{a: a, f: f}

  def take(nil), do: []
  def take(a), do: a
end
