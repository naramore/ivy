defprotocol Ivy.IfU do
  @fallback_to_any true

  def ifu(b, gs, c)
end

defimpl Ivy.IfU, for: Function do
  import Ivy.Macros, only: [inc: 1]

  def ifu(b, gs, c) do
    inc do
      @protocol.ifu(b.(), gs, c)
    end
  end
end

defimpl Ivy.IfU, for: Any do
  def ifu(nil, _, c), do: c
end
