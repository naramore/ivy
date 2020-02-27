defmodule Ivy.Database do
  alias Ivy.{Anomaly, Connection, Datom, Transaction}

  @type index(x) :: %{
    eavt: x,
    avet: x,
    aevt: x,
    vaet: x
  }

  defstruct [:conn, :memidx, :memlog, :ids, :keys, :elements, :basis, :index, :index_basis, :history, :filters, :since, :as_of, :raw?, :stream_index]
  @type t :: %__MODULE__{
    conn: Connection.t,
    memidx: index([Datom.t]),
    memlog: [Transaction.t],
    ids: %{required(Ivy.ident) => Ivy.id},
    keys: %{required(Ivy.id) => Ivy.ident},
    elements: %{required(Ivy.id) => Ivy.entity},
    basis: Ivy.basis,
    index: index([Cursor.t] | nil),
    index_basis: Ivy.basis,
    history: index(term),  # TODO: figure this out from Datomic
    filters: [Ivy.db_filter] | nil,
    since: Ivy.basis | nil,
    as_of: Ivy.basis | nil,
    raw?: boolean,
    stream_index: Datom.index | nil
  }

  # pull
  # q
  # tx_range
  # with_db

  @spec datoms(t, Datom.index, [Ivy.datom_opt]) :: Ivy.sync_resp([Datom.t])
  def datoms(%{raw?: true} = _db, _index, _opts) do
    # maybe update opts.start/end from since/as_of/index_basis
    # Enum.map Cursor.datoms/3
    # Enum.filter db.memidx.index on since/as_of/index_basis
    # apply filters
    # Enum.concat(remote_datoms, mem_datoms)
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end
  def datoms(_db, _index, _opts) do
    # maybe update opts.start/end from since/as_of/index_basis
    # Enum.map Cursor.datoms/3 w/ added?==true
    # Enum.filter db.memidx.index on since/as_of/index_basis/added?==true
    # apply filters
    # Enum.concat(remote_datoms, mem_datoms)
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec entity(t, Ivy.id, [Ivy.opt]) :: Ivy.sync_resp(Ivy.entity)
  def entity(db, entity_id, opts \\ [])
  def entity(%{raw?: true}, _entity_id, _opts) do
    {:error, Anomaly.new(:unsupported, "entity queries are not supported on history dbs")}
  end
  def entity(db, entity_id, opts) do
    with nil <- Map.get(db.elements, entity_id),
         {:ok, datoms} <- datoms(db, :eavt, Keyword.put(opts, :raw?, false)) do
      to_entity(db, datoms)
    else
      {:error, reason} -> {:error, reason}
      entity -> {:ok, entity}
    end
  end

  @spec to_entity(t, [Datom.t]) :: Ivy.entity
  defp to_entity(db, datoms) do
    Enum.reduce(datoms, %{}, fn
      %{added?: false}, e -> e
      d, e -> Map.put(e, Ivy.ident(db, d.a), d.v)
    end)
  end

  @spec pull(t, selector :: term, Ivy.id, [Ivy.opt]) :: Ivy.sync_resp(map)
  def pull(_db, _selector, _entity_id, _opts \\ []) do
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  # implement:
  #   schema / attributes
  #   tx_data -> [datom] translation
  #   transact + all properties of https://docs.datomic.com/cloud/transactions/transaction-processing.html
  #   datoms
  #   query
  #   pull
  #   query / transact functions
  #   entity / attr functions

  # q([find: ~v[name],
  #    where: [[~v[_], ~k[db.install/attribute], ~v[a]],
  #            [~v[a], ~k[db/ident], ~v[name]]]],
  #   [db])

  # run all [q] do
  #   fresh [e a name] do
  #     query(db, [e, ~k[db.install/attribute], a])
  #     query(db, [a, ~k[db/ident], name])
  #     unify(q, name)
  #   end
  # end

  @spec q(query :: term, args :: [term], [Ivy.opt]) :: Ivy.sync_resp([tuple])
  def q(_query, _args, _opts \\ []) do
    # translate query + args -> Ivy.Logic goals -> Ivy.Logic.run/4
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  defimpl Enumerable do
    alias Ivy.Database.Cursor

    def slice(_db), do: {:error, __MODULE__}
    def member?(_db, _element), do: {:error, __MODULE__}

    def count(db) do
      case Map.get(db.index, db.stream_index) do
        nil -> {:error, __MODULE__}
        cursors ->
          {:ok, Enum.map(cursors, &Cursor.count/1) |> Enum.sum()}
      end
    end

    def reduce(d, acc, reducer) do
    end
  end

  defimpl Inspect do
    def inspect(db, _opts) do
      "Ivy.Database@#{db.basis}"
    end
  end
end

Ivy.Core
  Anomaly
  Attribute
  Connection (defprotocol)
  Database (defprotocol)
  Datom
  Entity
  Transaction
  Utils
Ivy.Logic
Ivy.CLI
Ivy.Console
Ivy.Analytics
Ivy.Client
  Async
  Connection (impl Ivy.Connection)
  Database (impl Ivy.Database)
Ivy.PeerServer (e.g. phoenix jsonrpc)
Ivy.Peer
  Comm
  Query
    LiveIndex (behaviour)
      @callback handle_publish(...) :: ...
    Cache (behaviour)
      @callback datoms(...) :: ...
      ...
  Connection (impl Ivy.Connection)
  Database (impl Ivy.Database)
  Log
Ivy.Transactor (behaviour)
  @callback handle_transact(db, tx_data, state) :: ...
  @callback commit(...) :: ...
  @callback index(...) :: ...
  @callback publish(...) :: ...
  Indexer (behaviour)
    @callback handle_index(transacted, state) :: ...
    @callback index(...) :: ...
  DatabaseSupervisor
    DatabaseServer
Ivy.Storage (behaviour)
  @callback handle_commit(...) :: ...
  @callback handle_index(...) :: ...
Ivy.SimpleStorage (ie. in-memory impl of Ivy.Storage)




# Process Tree:
#   Ivy.Client (talks to peer server via HTTP)
#   Ivy.Peer
#     Ivy.PeerServer (exposes external HTTP API for clients)
#     Ivy.Query (used by Connection, & Database structs)
#       Ivy.Query.Cache (subscribes to remote storage(s) and cache(s))
#       Ivy.Query.LiveIndex (subscribes to Transactor)
#     Ivy.Comm (communicates with transactor)
#     Ivy.Connection.Supervisor
#       Ivy.Connection
#   Ivy.Remote
#     Ivy.Remote.TransactorSupervisor
#       Ivy.Remote.Transactor (receives transact requests & publishes results to subscribed live caches)
#       Ivy.Remote.Indexer (subscribes to transactor & updates storage)
#     Ivy.Remote.Cache
#     Ivy.Remote.Storage
# Behaviours:
# Protocols:
# Data:
#   Ivy.Anomaly
#   Ivy.Attribute
#   Ivy.Connection
#   Ivy.Database
#   Ivy.Datom
#   Ivy.Entity
#   Ivy.Log
#   Ivy.Transaction

# @type async_resp(t) ::
#   (timeout -> {:ok, t} | {:error, Anomaly.t} | nil) |
#   (() -> {:ok, t} | {:error, Anomaly.t} | nil)
# Peer
#   @spec connect(client) :: {:ok, Connection.t} | {:error, Anomaly.t}
#   @spec create_database(client, db_name) :: :ok | {:error, Anomaly.t}
#   @spec delete_database(client, db_name) :: :ok | {:error, Anomaly.t}
#   @spec list_databases(client) :: {:ok, [db_name]} | {:error, Anomaly.t}
#   @spec function() :: term
#   @spec part(t, id) :: ident | nil
#   @spec q() :: term
#   @spec query() :: term
#   @spec resolve_temp_id() :: term
#   @spec shutdown() :: term
#   @spec squuid() :: term
#   @spec squuid_time(uuid, time_unit) :: term
#   @spec temp_id() :: term
#   @spec to_t() :: term
#   @spec to_tx() :: term
# Connection
#   @spec db(t) :: Database.t
#   @spec gc_storage(DateTime.t) :: :ok
#   @spec log(t) :: Log.t
#   @spec release(t) :: :ok
#   @spec remove_tx_report_queue(t) :: :ok
#   @spec request_index(t) :: boolean
#   @spec sync(t) :: async_resp(Database.t)
#   @spec sync(t, t_value) :: async_resp(Database.t)
#   @spec sync_excise(t, t_value) :: async_resp(Database.t)
#   @spec sync_index(t, t_value) :: async_resp(Database.t)
#   @spec sync_schema(t, t_value) :: async_resp(Database.t)
#   @spec transact(t, tx_data, keyword) :: {:ok, transacted} | {:error, Anomaly.t}
#   @spec transact_async(t, tx_data, keyword) :: async_resp(transacted)
#   @spec tx_report_queue(t) :: queue(transacted)
# Database
#   @spec as_of(t, t_value) :: t
#   @spec as_of_t(t) :: t_value | nil
#   @spec attribute(t, attr_id) :: Attribute.t | nil
#   @spec basis_t(t) :: t_value
#   @spec datoms(t, index, components) :: Stream.t(Datom.t)
#   @spec seek_datoms(t, index, components) :: Stream.t(Datom.t)
#   @spec entity_id(t, ident) :: id | nil
#   @spec entity_id_at(t, ident, time_point) :: id | nil
#   @spec entity(t, id) :: Entity.t
#   @spec filter(t, database_predicate) :: t
#   @spec history(t) :: t
#   @spec id(t) :: UUID.t
#   @spec ident(t, id | ident) :: ident | nil
#   @spec index_range(t, ident, time_point, time_point) :: Stream.t(Datom.t)
#   @spec invoke!(t, id, args) :: result
#   @spec filtered?(t) :: boolean
#   @spec history?(t) :: boolean
#   @spec next_t(t) :: t_value
#   @spec pull(pattern, id) :: map | nil
#   @spec pull_many(pattern, [id]) :: [map | nil]
#   @spec since(t, t_value) :: t
#   @spec since_t(t) :: t_value | nil
#   @spec with_db(t, tx_data) :: {:ok, transacted} | {:error, Anomaly.t}
# Entity
#   @spec db(t) :: Database.t
#   @spec get(t, atom) :: value | [value] | Entity.t | [Entity.t] | nil
#   @spec keys(t) :: [atom]
#   @spec touch(t) :: t
# Log
#   @spec tx_range(t, time_point, time_point, keyword) :: async_resp([Transaction.t])
