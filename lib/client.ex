defmodule Ivy.Client do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Connection, Database, Pull, Query, Transaction}

  @type client :: map
  @type action :: term
  @type args :: map
  @type diagnosis :: term
  @type time_point :: term
  @type stats :: %{
    required(:datoms) => non_neg_integer,
    optional(atom) => term
  }

  @type sync_resp(r) :: {:ok, r} | {:error, Anomaly.t}
  @type sync_resp :: :ok | {:error, Anomaly.t}
  @type opts :: keyword

  # TODO: all callback -> spec + impl them
  @callback administer_system(client, action, args, opts) :: sync_resp(diagnosis)
  @callback as_of(Database.t, time_point) :: Database.t
  @callback client(opts) :: {:ok, client} | {:error, reason :: term}
  @callback connect(client, Core.name, opts) :: sync_resp(Connection.t)
  @callback create_database(client, Core.name, opts) :: sync_resp
  @callback datoms(Database.t, Datom.index, Datom.components, opts) :: sync_resp([Datom.t])
  @callback db(Connection.t) :: Database.t
  @callback db_stats(Database.t, opts) :: sync_resp(stats)
  @callback delete_database(client, Core.name, opts) :: sync_resp
  @callback history(Database.t) :: Database.t
  @callback index_range(Database.t, Core.id, time_point, time_point, opts) :: sync_resp([Datom.t])
  @callback list_databases(client, opts) :: sync_resp([Core.name])
  @callback pull(Database.t, Pull.t, Core.id, opts) :: sync_resp(map)
  @callback q(Query.t, Query.args, opts) :: sync_resp([tuple])
  @callback since(Database.t, time_point) :: Database.t
  @callback sync(Connection.t, time_point, opts) :: sync_resp(Database.t)
  @callback transact(Connection.t, Transaction.data, opts) :: sync_resp(Transaction.transacted)
  @callback tx_range(Connection.t, time_point, time_point, opts) :: sync_resp([Transaction.t])
  @callback with_db(Database.t, Transaction.data, opts) :: sync_resp(Transaction.transacted)
end
