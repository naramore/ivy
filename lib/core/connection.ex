defprotocol Ivy.Core.Connection do
  alias Ivy.Core
  alias Ivy.{Anomaly, Database, Log, Transaction}

  @type sync_type :: :tx | :excise | :index | :schema

  @spec db(t) :: Database.t
  def db(conn)

  @spec log(t) :: Log.t
  def log(conn)

  @spec sync(t, Core.time_point, sync_type, keyword) :: {:ok, Database.t} | {:error, Anomaly.t}
  def sync(conn, t \\ nil, type \\ :tx, opts \\ [])

  @spec transact_async(t, Transaction.data, keyword) :: :ok | {:error, Anomaly.t}
  def transact_async(conn, tx_data, opts \\ [])

  @spec gc_storage(t, DateTime.t) :: :ok
  def gc_storage(conn, older_than)

  @spec release(t) :: :ok
  def release(conn)

  @spec request_index(t, keyword) :: {:ok, boolean} | {:error, Anomaly.t}
  def request_index(conn, opts \\ [])
end
