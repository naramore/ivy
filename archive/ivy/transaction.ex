defmodule Ivy.Transaction do
  alias Ivy.Datom

  @enforce_keys [:t, :data]
  defstruct [:t, :instant, :id, data: [], attributes: %{}]
  @type t :: %__MODULE__{
    t: non_neg_integer,
    instant: DateTime.t,
    id: Ivy.id,
    data: [Datom.t],
    attributes: %{optional(Ivy.ident) => Datom.value}
  }
end
