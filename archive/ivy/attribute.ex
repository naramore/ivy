defmodule Ivy.Attribute do
  import AtomUtils
  alias Ivy.{Anomaly, Database, Datom, Transaction}

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
    ident: Ivy.ident,
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

  # @spec parse(tx_data, Database.t) :: {:ok, Transaction.t} | {:error, Anomaly.t}
  #   translate updates -> [Datom.t] + tx_datom
  #   idents -> ids
  #   reified tx (via :db/id "ivy.tx")
  #   explicit :db/tx_instant
  # @spec resolve(Transaction.t, Database.t) :: {:ok, Database.t} | {:error, Anomaly.t}
  #   temp_id resolution
  #   add idents to db.keys & db.ids
  #   add attributes to db.elements
  #   update index, memidx, & memlog
  # @spec validate(Transaction.t, Database.t) :: :ok | {:error, Anomaly.t}
  #   redundancy elimination (i.e. existing datom that differs only by tx_id)
  # @spec validate(Datom.t, Transaction.t, Database.t) :: {:ok, :add | :retract | :swap | :noop} | {:error, Anomaly.t}
  #   lookup attribute
  #   redundancy elimination (i.e. existing datom that differs only by tx_id)
  #   virtual datom handling (e.g. :db/ensure)
  # @spec validate(Attribute.t, Datom.t, Transaction.t, Database.t) :: :ok | {:error, Anomaly.t}
  #   typing
  #   predicates
  #   identity uniqueness
  #   value uniqueness
  #   :db.type/ref -> verify the entity referenced exists in the txn + db
  #   :db/ident id / atom is registered in db (or in tx)

  @spec validate(t, Datom.t, Transaction.t, Database.t) :: :ok | {:error, Anomaly.t}
  def validate(_attribute, _datom, _tx, _db) do
  end

  @spec typed?(t, Datom.value, boolean) :: :ok | {:error, Anomaly.t}
  defp typed?(attribute, value, only_scalar? \\ false)
  defp typed?(%{value_type: :integer}, val, _) when is_integer(val), do: true
  defp typed?(%{value_type: :float}, val, _) when is_float(val), do: true
  defp typed?(%{value_type: :boolean}, val, _) when is_boolean(val), do: true
  defp typed?(%{value_type: :atom}, val, _) when is_atom(val), do: true
  defp typed?(%{value_type: :string}, val, _) when is_bitstring(val), do: true
  defp typed?(%{value_type: :uri}, %URI{}, _), do: true
  defp typed?(%{value_type: :datetime}, %DateTime{}, _), do: true
  defp typed?(%{value_type: :ref}, val, _), do: Datom.ref?(val)
  defp typed?(%{value_type: :uuid}, val, _), do: match?({:ok, _}, UUID.info(val))
  defp typed?(%{value_type: :tuple} = attr, val, false)
    when is_tuple(val) and tuple_size(val) in 2..8 do
      # case attr do
      #   %{tuple_attrs: ta} when not is_nil(ta) -> false
      #   %{tuple_types: ts} when length(ts) == tuple_size(val) ->
      #     Tuple.to_list(val)
      #     |> Enum.zip(ts)
      #     |> Enum.reduce_while()
      #   %{tuple_type: t} ->
      #     Tuple.to_list(val)
      #     |> Enum.all?(&typed?())
      #   _ -> false
      # end
  end
  defp typed?(_, _, _), do: false

  # TODO: ...
  @spec apply_preds([attr_pred] | nil, Datom.value) :: :ok | {:error, Anomaly.t}
  defp apply_preds(nil, val), do: :ok
  defp apply_preds([], val), do: :ok
  defp apply_preds([p | ps], val) do
    case execute(p, [val]) do
      true -> apply_preds(ps, val)
      _ -> {:error, p}
    end
  end

  defp execute(fun, args) do
    case fun do
      f when is_function(f, length(args)) -> apply(f, args)
      {m, f} -> apply(m, f, args)
    end
  rescue
    exception -> {:error, exception}
  catch
    :exit, reason -> {:error, reason}
    thrown -> {:error, thrown}
  end

  @attribute_keys [
    :"db/ident",
    :"db/cardinality",
    :"db/value_type"
  ]

  @spec attribute?(term) :: boolean
  def attribute?(datoms) when is_list(datoms) do
    Enum.all?()
  end
  def attribute?(map) when is_map(map) do
    Enum.all?(@attribute_keys, &Map.has_key?(map, &1))
  end
  def attribute?(_), do: false

  @spec from_datoms(Database.t, [Datom.t]) :: t
  def from_datoms(_db, _datoms) do
  end
end
