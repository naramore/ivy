defmodule Ivy.Core.Transaction do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Datom, Database}

  @type data :: term
  @type transacted :: %{
    db_before: Database.t,
    db_after: Database.t,
    tx_data: [Datom.t],
    temp_ids: %{optional(Core.temp_id) => Core.id}
  }

  @enforce_keys [:t, :data]
  defstruct [:t, data: []]
  @type t :: %__MODULE__{
    t: Core.t_value,
    data: [Datom.t]
  }

  @spec transact(Database.t, data, keyword) :: {:ok, transacted} | {:error, Anomaly.t}
  def transact(db, tx_data, _opts \\ []) do
    with {:ok, tx} <- parse(tx_data, db),
         {:ok, tx} <- validate(tx, db),
         {:ok, db_after} <- resolve(tx, db) do
      {:ok, %{
        db_before: db,
        db_after: db_after,
        tx_data: tx.data,
        temp_ids: %{}
      }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec parse(data, Database.t) :: {:ok, t} | {:error, Anomaly.t}
  def parse(_tx_data, _db) do
    # translate updates -> [Datom.t] + tx_datom
    # idents -> ids
    # reified tx (via :db/id "ivy.tx")
    # explicit :db/tx_instant
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec validate(t, Database.t) :: {:ok, t} | {:error, Anomaly.t}
  def validate(_tx, _db) do
    # redundancy elimination (i.e. existing datom that differs only by tx_id)
    # call Datom.validate/3 for each datom
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec resolve(t, Database.t) :: {:ok, Database.t} | {:error, Anomaly.t}
  def resolve(_tx, _db) do
    # typing
    # predicates
    # identity uniqueness
    # value uniqueness
    # :db.type/ref -> verify the entity referenced exists in the txn + db
    # :db/ident id / atom is registered in db (or in tx)
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end
end
