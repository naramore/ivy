defmodule Ivy.Core.Attribute do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Database, Datom, Transaction}

  @type cardinality :: :one | :many
  @type unique :: :identity | :value
  @type type :: :integer | :float | :boolean |
                :instant | :atom | :ref |
                :string | :tuple | :uuid |
                :uri
  @type attr_pred :: {module, atom, 1} | (Datom.value -> boolean)

  @enforce_keys [:ident, :cardinality, :value_type]
  defstruct [:ident, :cardinality, :value_type, :id, :doc, :unique, :attr_preds,
             is_component: false, no_history: false, index: false]
  @type t :: %__MODULE__{
    ident: Core.ident,
    cardinality: cardinality,
    value_type: type,
    doc: String.t | nil,
    unique: unique | nil,
    is_component: boolean | nil,
    id: Datom.ref | nil,
    no_history: boolean | nil,
    attr_preds: [attr_pred, ...] | nil,
    index: boolean | nil
  }

  @spec validate(t, Datom.t, Transaction.t, Database.t) :: :ok | {:error, Anomaly.t}
  def validate(_attr, _datom, _tx, _db) do
    # typing
    # predicates
    # identity uniqueness
    # value uniqueness
    # :db.type/ref -> verify the entity referenced exists in the txn + db
    # :db/ident id / atom is registered in db (or in tx)
    {:error, Anomaly.new(:unsupported, "not implemented")}
  end

  @spec attribute?(term) :: boolean
  def attribute?(_term) do
    false
  end

  @spec from_datoms([Datom.t], Database.t) :: {:ok, t} | {:error, reason :: term}
  def from_datoms(_datoms, _database) do
    {:error, Anomaly.new(:unsupported, "not implemented")}
  end
end
