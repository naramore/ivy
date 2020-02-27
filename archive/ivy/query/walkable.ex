defprotocol Ivy.Walkable do
  @fallback_to_any true

  def walk(v, f)
end

defimpl Ivy.Walkable, for: List do
  def walk([], _), do: []
  def walk([h | t], f) when is_list(t) do
    [@protocol.walk(f.(h), f) | @protocol.walk(t, f)]
  end
  def walk([h | t], f) do
    [f.(h) | f.(t)]
  end
end

defimpl Ivy.Walkable, for: Map do
  def walk(v, f) do
    walk_impl(Enum.into(v, []), f, %{})
  end

  defp walk_impl([], _, acc), do: acc
  defp walk_impl([{key, val} | t], f, acc) do
    walk_impl(t, f,
      Map.put(acc,
        @protocol.walk(f.(key), f),
        @protocol.walk(f.(val), f)
      )
    )
  end
end

defimpl Ivy.Walkable, for: Any do
  def walk(nil, f), do: f.(nil)
  def walk(v, f), do: f.(v)
end
