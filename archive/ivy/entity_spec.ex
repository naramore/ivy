defmodule Ivy.EntitySpec do
  alias Ivy.{Database, Datom}

  @type entity_pred :: {module, atom, 2} | (Database.t, Datom.eid -> boolean)

  defstruct [:ident, :id, :doc, :entity_attrs, :entity_preds, index: false]
  @type t :: %__MODULE__{
    ident: Ivy.ident | nil,
    id: Datom.ref | nil,
    doc: String.t | nil,
    entity_attrs: [Ivy.ident] | nil,
    entity_preds: [entity_pred, ...] | nil,
    index: boolean | nil
  }
end
