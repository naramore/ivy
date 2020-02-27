# TODO: convert from protocol to concrete struct?
#       transact/3 is possible using the Ivy.Database.Index protocol's add and retract
#       db/2 & sync/3 should be able to be made concrete as well...
defprotocol Ivy.Connection do
  alias Ivy.Database

  @spec db(t, [Ivy.opt]) :: Ivy.sync_resp(Database.t)
  def db(conn, opts \\ [])
  # ???

  @spec sync(t, Ivy.basis | nil, [Ivy.sync_opt]) :: Ivy.sync_resp(Database.t)
  def sync(conn, t \\ nil, opts \\ [])
  # ???

  @spec transact(t, tx_data :: term, [Ivy.opt]) :: Ivy.sync_resp(Ivy.transacted)
  def transact(conn, tx_data, opts \\ [])
  # NOTE: this is what the Transactor should do remotely...
  # {:ok, db} = db(conn, opts)
  # Transaction.transact(db, tx_data, opts)
  #   {:ok, tx} = parse(tx_data, db)
  #   {:ok, tx} = validate(tx, db)
  #   {:ok, db_after, temp_ids} = resolve(tx, db)
  #   {:ok, %{db_before: db, db_after: db_after, datoms: tx.data, temp_ids: temp_ids}}
end
