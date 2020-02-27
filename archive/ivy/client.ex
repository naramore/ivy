defprotocol Ivy.Client do
  alias Ivy.Connection

  @spec new(t, keyword) :: {:ok, t} | {:error, reason :: term}
  def new(client, options)

  @spec connect(t, Ivy.name, [Ivy.opt]) :: Ivy.sync_resp(Connection.t)
  def connect(client, db_name, options \\ [])

  @spec create_database(t, Ivy.name, [Ivy.opt]) :: Ivy.sync_resp
  def create_database(client, db_name, opts \\ [])

  @spec delete_database(t, Ivy.name, [Ivy.opt]) :: Ivy.sync_resp
  def delete_database(client, db_name, opts \\ [])

  @spec list_databases(t, [Ivy.opt]) :: Ivy.sync_resp([Ivy.name])
  def list_databases(client, opts \\ [])
end
