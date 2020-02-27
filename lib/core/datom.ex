defmodule Ivy.Core.Datom do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Database, Transaction}

  @behaviour Access

  @type value :: String.t | atom | boolean | ref | DateTime.t | UUID.t | number
  @type ref :: ivy_identifier | Core.temp_id
  @type ivy_identifier :: eid | lookup_ref | Core.ident
  @type lookup_ref :: {ivy_identifier, value}

  @type eid :: Core.id
  @type attr_id :: Core.id
  @type index :: :eavt | :aevt | :avet | :vaet
  @type components :: term

  @enforce_keys [:e, :a, :v, :tx, :added?]
  defstruct [:e, :a, :v, :tx, added?: true]
  @type t :: %__MODULE__{
    e: eid,
    a: attr_id,
    v: value,
    tx: Core.tx_id,
    added?: boolean
  }

  @impl Access
  def fetch(datom, key) do
    Map.fetch(datom, get_key(key))
  end

  @impl Access
  def pop(datom, key) do
    Map.pop(datom, get_key(key))
  end

  @impl Access
  def get_and_update(datom, key, fun) do
    Map.get_and_update(datom, get_key(key), fun)
  end

  @mapping %{
    0 => :e,
    1 => :a,
    2 => :v,
    3 => :tx,
    4 => :added?
  }

  @compile {:inline, get_key: 1}
  @spec get_key(integer | atom) :: atom
  defp get_key(key) when key in 0..4, do: Map.get(@mapping, key)
  defp get_key(key), do: key

  @spec to_list(t) :: [term]
  def to_list(datom) do
    [datom.e, datom.a, datom.v, datom.tx, datom.added?]
  end

  @spec match?(t, components, index) :: boolean
  def match?(_datom, nil), do: true
  def match?(%{e: e}, [e], :eavt), do: true
  def match?(%{e: e, a: a}, [e, a], :eavt), do: true
  def match?(%{e: e, a: a, v: v}, [e, a, v], :eavt), do: true
  def match?(%{e: e, a: a, v: v, tx: t}, [e, a, v, t], :eavt), do: true
  def match?(%{a: a}, [a], :aevt), do: true
  def match?(%{a: a, e: e}, [a, e], :aevt), do: true
  def match?(%{a: a, e: e, v: v}, [a, e, v], :aevt), do: true
  def match?(%{a: a, e: e, v: v, tx: t}, [a, e, v, t], :aevt), do: true
  def match?(%{a: a}, [a], :aevt), do: true
  def match?(%{a: a, v: v}, [a, v], :aevt), do: true
  def match?(%{a: a, v: v, e: e}, [a, v, e], :aevt), do: true
  def match?(%{a: a, v: v, e: e, tx: t}, [a, v, e, t], :aevt), do: true
  def match?(%{v: v}, [v], :vaet), do: true
  def match?(%{v: v, a: a}, [v, a], :vaet), do: true
  def match?(%{v: v, a: a, e: e}, [v, a, e], :vaet), do: true
  def match?(%{v: v, a: a, e: e, tx: t}, [v, a, e, t], :vaet), do: true
  def match?(_, _, _), do: false

  @spec validate(t, Transaction.t, Database.t) :: {:ok, :add | :retract | :swap | :noop} | {:error, Anomaly.t}
  def validate(_datom, _tx, _db) do
    # lookup attribute
    # redundancy elimination (i.e. existing datom that differs only by tx_id)
    # virtual datom handling (e.g. :db/ensure)
    {:error, Anomaly.new(:unsupported, "not implemented")}
  end

  @spec collapse(Enumerable.t) :: {:ok, [t]} | {:error, Anomaly.t}
  def collapse(datoms) do
    datoms
    |> Enum.group_by(&{&1.e, &1.a, &1.v})
    |> Enum.map(fn {_, datoms} ->
      datoms
      |> Enum.reverse()
      |> Enum.find(&(&1.added?))
    end)
    |> Enum.reject(&is_nil/1)
  end

  defimpl Enumerable do
    def count(_datom), do: {:ok, 5}
    def member?(_datom, _element), do: {:error, __MODULE__}
    def slice(_datom), do: {:error, __MODULE__}
    def reduce(d, acc, reducer) do
      @protocol.reduce(@for.to_list(d), acc, reducer)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(datom, opts) do
      container_doc("#datom[", datom, "]", opts, &@protocol.inspect/2, break: :flex, separator: " ")
    end
  end
end
