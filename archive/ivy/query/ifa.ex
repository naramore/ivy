defprotocol Ivy.IfA do
  @fallback_to_any true

  def ifa(b, gs, c)
end

defimpl Ivy.IfA, for: Function do
  import Ivy.Macros, only: [inc: 1]

  def ifa(b, gs, c) do
    inc do
      @protocol.ifa(b.(), gs, c)
    end
  end
end

defimpl Ivy.IfA, for: Any do
  def ifa(nil, _, c), do: c
end
