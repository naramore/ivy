defprotocol Ivy.Logical do
  alias Ivy.Package

  @fallback_to_any true

  @spec reify(t, Package.t) :: Package.t
  def reify(v, s)

  @spec occurs?(t, t, Package.t) :: boolean
  def occurs?(v, x, s)

  @spec build(t, Package.t) :: Package.t
  def build(u, s)
end

defimpl Ivy.Logical, for: List do
  alias Ivy.Package

  def reify([], s), do: s
  def reify([h | t], s) do
    reify(t, Package.reify(s, h))
  end

  def occurs?([], _, _), do: false
  def occurs?([h | t], x, s) do
    Package.occurs?(s, x, h) or occurs?(t, x, s)
  end

  def build(u, s) do
    Enum.reduce(u, s, &@protocol.build/2)
  end
end

defimpl Ivy.Logical, for: Map do
  def reify(v, s) do
    @protocol.reify(Enum.into(v, []), s)
  end

  def occurs?(v, x, s) do
    @protocol.occurs?(Enum.into(v, []), x, s)
  end

  def build(u, s) do
    @protocol.build(Enum.into(u, []), s)
  end
end

defimpl Ivy.Logical, for: Any do
  def reify(_, s), do: s

  def occurs?(_, _, _), do: false

  def build(_, s), do: s
end
