defmodule Ivy.Core.Database do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Attribute, Database, Datom, Entity, Index, Pull, Transaction}

  @type partition :: term
  @type predicate :: (Datom.t, Database.t -> boolean)
  @type entity :: %{
    required(:id) => Core.id,
    optional(atom) => Datom.value | entity | [Datom.value] | [entity]
  }

  defstruct [:as_of_t, :since_t, :basis_t, :next_t,
             :filters, :index, :id, history?: false,
             ids: %{}, keys: %{}, elements: %{}]
  @type t :: %__MODULE__{
    id: String.t,
    index: Index.t,
    ids: %{required(Core.ident) => Core.id},
    keys: %{required(Core.id) => Core.ident},
    elements: %{required(Core.id) => entity},
    filters: [predicate] | nil,
    history?: boolean,
    as_of_t: Core.t_value,
    since_t: Core.t_value,
    basis_t: Core.t_value,
    next_t: Core.t_value,
  }

  @spec as_of(t, Core.t_value) :: t
  def as_of(database, t) do
    Map.put(database, :as_of_t, t)
  end

  @spec as_of_t(t) :: Core.t_value | nil
  def as_of_t(database) do
    database.as_of_t
  end

  @spec attribute(t, Core.id) :: Attribute.t | nil
  def attribute(database, attr_id) do
    Map.get(database.elements, attr_id)
  end

  @spec basis_t(t) :: Core.t_value
  def basis_t(database) do
    database.basis_t
  end

  @spec datoms(t, Datom.index, Datom.components, keyword) :: {:ok, Stream.t(Datom.t | Anomaly.t)} | {:error, Anomaly.t}
  def datoms(database, index, components \\ nil, opts \\ []) do
    case seek_datoms(database, index, components, opts) do
      {:error, reason} -> {:error, reason}
      {:ok, stream} ->
        {:ok, Stream.take_while(stream, fn
          %Anomaly{} -> true
          datom -> Datom.match?(datom, components, index)
        end)}
    end
  end

  @spec entid(t, Core.id) :: Core.ident | nil
  def entid(database, ident) when is_atom(ident) do
    Map.get(database.ids, ident)
  end
  def entid(database, id) when is_integer(id) do
    if Map.has_key?(database.keys, id), do: id
  end
  def entid(_, _), do: nil

  @spec entid_at(t, partition, Core.time_point, keyword) :: {:ok, Core.id} | {:error, Anomaly.t}
  def entid_at(database, partition, time_point, opts \\ []) do
    Index.entid_at(database.index, partition, time_point, opts)
  end

  @spec entity(t, Core.id) :: Entity.t
  def entity(database, entity_id) do
    Entity.new(database, entity_id)
  end

  @spec filter(t, predicate) :: t
  def filter(database, pred) do
    Map.update(database, :filters, [pred], &[pred | &1])
  end

  @spec history(t) :: t
  def history(database) do
    Map.put(database, :history?, true)
  end

  @spec id(t) :: String.t
  def id(database), do: database.id

  @spec ident(t, Core.id | Core.ident) :: Core.ident | nil
  def ident(database, id) when is_integer(id) do
    Map.get(database.keys, id)
  end
  def ident(database, ident) when is_atom(ident) do
    if Map.has_key?(database.ids, ident), do: ident
  end
  def ident(_, _), do: nil

  @spec index_range(t, Core.id, Core.time_point | nil, Core.time_point | nil, keyword) :: {:ok, Stream.t(Datom.t | Anomaly.t)} | {:error, Anomaly.t}
  def index_range(database, attr_id, start \\ nil, finish \\ nil, opts \\ []) do
    start = convert_time_point_to_tx_id(database, start)
    finish = convert_time_point_to_tx_id(database, finish)
    case datoms(database, :avet, [attr_id], opts) do
      {:error, reason} -> {:error, reason}
      {:ok, stream} ->
        {:ok, stream
          |> Stream.drop_while(fn
            %Anomaly{} -> false
            %Datom{tx: tx} -> not is_nil(start) and tx < start
          end)
          |> Stream.take_while(fn
            %Anomaly{} -> true
            %Datom{tx: tx} -> is_nil(finish) or tx < finish
          end)}
    end
  end

  @spec convert_time_point_to_tx_id(Database.t, Core.time_point | nil) :: Core.tx_id | nil
  defp convert_time_point_to_tx_id(_database, nil), do: nil
  defp convert_time_point_to_tx_id(_database, _time_point) do
    # TODO: implement...
  end

  @spec invoke(t, Core.id, [term], keyword) :: {:ok, term} | {:error, Anomaly.t}
  def invoke(database, entity_id, args, _opts \\ []) do
    case Map.get(database.elements, entity_id) do
      %{function: {mod, fun}} -> apply(mod, fun, args)
      nil -> {:error, Anomaly.new(:not_found, "function not found")}
      _ -> {:error, Anomaly.new(:incorrect, "invalid function specification")}
    end
  rescue
    error -> {:error, Anomaly.new(:fault, "function raised with: #{error}")}
  catch
    :exit, reason -> {:error, Anomaly.new(:fault, "function exited with: #{inspect(reason)}")}
    thrown -> {:error, Anomaly.new(:fault, "function threw: #{inspect(thrown)}")}
  end

  @spec filtered?(t) :: boolean
  def filtered?(database) do
    not is_nil(database.filters) and length(database.filters) > 0
  end

  @spec history?(t) :: boolean
  def history?(database), do: database.history?

  @spec next_t(t) :: Core.t_value
  def next_t(database), do: database.next_t

  @spec pull(t, Pull.t, Core.id | [Core.id], keyword) :: {:ok, map | [map]} | {:error, Anomaly.t}
  def pull(_database, _pattern, _ids, _opts \\ []) do
    {:error, Anomaly.new(:unsupported, "not implemented yet")}
  end

  @spec seek_datoms(t, Datom.index, Datom.components, keyword) :: {:ok, Stream.t(Datom.t | Anomaly.t)} | {:error, Anomaly.t}
  def seek_datoms(database, index, components \\ nil, opts \\ []) do
    Index.seek_datoms(database.index, index, components, database.history?, opts)
  end

  @spec since(t, Core.t_value) :: t
  def since(database, t) do
    Map.put(database, :since_t, t)
  end

  @spec since_t(t) :: Core.t_value
  def since_t(database), do: database.since_t

  @spec with_db(t, Transaction.data, keyword) :: {:ok, Transaction.transacted} | {:error, Anomaly.t}
  def with_db(database, tx_data, opts \\ []) do
    Transaction.transact(database, tx_data, opts)
  end

  defimpl Inspect do
    def inspect(database, _opts) do
      "Ivy.Core.Database@#{database.basis_t}"
    end
  end
end
