defmodule Ivy do
  alias Ivy.{Anomaly, Attribute, Client, Connection, Database, Datom, Transaction}

  @type id :: non_neg_integer
  @type temp_id :: String.t
  @type ident :: atom
  @type basis :: DateTime.t | id
  @type name :: String.t | atom
  @type opt :: {:timeout, timeout} |
               {:offset, non_neg_integer} |
               {:limit, non_neg_integer | :infinity} |
               {:chunk, pos_integer} |
               {:stream_to, pid}
  @type db_filter :: (Database.t, Datom.t -> boolean) | {module, atom, 2}
  @type transacted :: %{
    db_before: Database.t,
    db_after: Database.t,
    tx_data: [Datom.t],
    temp_ids: %{optional(temp_id) => id}
  }
  @type entity :: %{
    required(:id) => id,
    optional(atom) => term
  }
  @type sync_resp(r) :: {:ok, r} | {:error, Anomaly.t}
  @type sync_resp :: :ok | {:error, Anomaly.t}

  @spec as_of(Database.t, basis) :: Database.t
  def as_of(db, t) do
    %{db | as_of: t}
  end

  @spec attribute(Database.t, id) :: Attribute.t | nil
  def attribute(db, attr_id) do
    Map.get(db.elements, attr_id)
  end

  @spec client(keyword) :: {:ok, Client.t} | {:error, reason :: term}
  def client(opts \\ []) do
    with {_, true} <- {:exists?, Keyword.has_key?(opts, :module)},
         {module, opts} <- Keyword.pop(opts, :module),
         {_, true} <- {:impls?, function_exported?(module, :new, 2)} do
      Client.new(struct(module, []), opts)
    else
      {:exists?, false} -> {:error, :unspecified_client_module}
      {:impls?, false} -> {:error, :invalid_client_module}
    end
  end

  @spec connect(Client.t, name, [opt]) :: sync_resp(Connection.t)
  def connect(client, db_name, opts \\ []) do
    Client.connect(client, db_name, opts)
  end

  @spec create_database(Client.t, name, [opt]) :: sync_resp
  def create_database(client, db_name, opts \\ []) do
    Client.create_database(client, db_name, opts)
  end

  @type range_opt :: opt | {:start, basis} | {:end, basis}
  @type datom_opt :: range_opt | {:components, [term]}

  @spec datoms(Database.t, Datom.index, [datom_opt]) :: sync_resp([Datom.t])
  def datoms(db, index, opts \\ []) do
    Database.datoms(db, index, opts)
  end

  @spec db(Connection.t, [opt]) :: sync_resp(Database.t)
  def db(conn, opts \\ []) do
    Connection.db(conn, opts)
  end

  @spec delete_database(Client.t, name, [opt]) :: sync_resp
  def delete_database(client, db_name, opts \\ []) do
    Client.delete_database(client, db_name, opts)
  end

  @spec entity_id(Database.t, term) :: id | nil
  def entity_id(db, ident) when is_atom(ident) do
    Map.get(db.ids, ident)
  end
  def entity_id(db, id) when is_integer(id) do
    if Map.has_key?(db.keys, id), do: id
  end
  def entity_id(_, _), do: nil

  @spec entity(Database.t, id, [opt]) :: sync_resp(entity)
  def entity(db, entity_id, opts \\ []) do
    Database.entity(db, entity_id, opts)
  end

  @spec filter(Database.t, db_filter) :: Database.t
  def filter(db, filter) do
    Map.update(db, :filters, [filter], &[filter | &1])
  end

  @spec history(Database.t) :: Database.t
  def history(db) do
    %{db | raw?: true}
  end

  @spec ident(Database.t, id) :: ident | nil
  def ident(db, id) when is_integer(id) do
    Map.get(db.keys, id)
  end
  def ident(db, ident) when is_atom(ident) do
    if Map.has_key?(db.ids, ident), do: ident
  end
  def ident(_, _), do: nil

  @spec list_databases(Client.t, [opt]) :: sync_resp([name])
  def list_databases(client, opts \\ []) do
    Client.list_databases(client, opts)
  end

  @spec pull(Database.t, selector :: term, id, [opt]) :: sync_resp(map)
  def pull(_db, _selector, _entity_id, _opts \\ []) do
    # TODO: implement Ivy.pull/4
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec q(query :: term, args :: [term], [opt]) :: sync_resp([tuple])
  def q(_query, _args, _opts \\ []) do
    # TODO: implement Ivy.q/3
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec since(Database.t, basis) :: Database.t
  def since(db, t) do
    %{db | since: t}
  end

  @type sync_opt :: opt | {:type, :basis | :excise | :index | :schema}

  @spec sync(Connection.t, basis | nil, [sync_opt]) :: sync_resp(Database.t)
  def sync(conn, t \\ nil, opts \\ []) do
    Connection.sync(conn, t, opts)
  end

  @spec transact(Connection.t, tx_data :: term, [opt]) :: sync_resp(transacted)
  def transact(conn, tx_data, opts \\ []) do
    Connection.transact(conn, tx_data, opts)
  end

  # @spec tx_id(Database.t | Connection.t, basis, [opt]) :: sync_resp(id)
  # def tx_id(_db_or_conn, _t, _opts \\ []) do
  #   # TODO: implement Ivy.tx_id/3
  #   {:error, Anomaly.new(:unsupported, "not implemented yet")}
  # end

  # @spec tx_basis(Database.t | Connection.t, id, [opt]) :: sync_resp(basis)
  # def tx_basis(_db_or_conn, _id, _opts \\ []) do
  #   # TODO: implement Ivy.tx_basis/2]3
  #   {:error, Anomaly.new(:unsupported, "not implemented yet")}
  # end

  @spec tx_range(Connection.t, [range_opt]) :: sync_resp([Transaction.t])
  def tx_range(_conn, _opts \\ []) do
    # TODO: implement Ivy.tx_range/2
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec with_db(Database.t, tx_data :: term, [opt]) :: sync_resp(transacted)
  def with_db(_db, _tx_data, _opts \\ []) do
    # TODO: implement Ivy.with_db/3
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end
end
