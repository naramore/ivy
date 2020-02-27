defmodule Ivy.Datom do
  @behaviour Access

  @type value :: String.t | atom | boolean | ref | DateTime.t | UUID.t | number
  @type ref :: ivy_identifier | Ivy.temp_id
  @type ivy_identifier :: eid | lookup_ref | Ivy.ident
  @type lookup_ref :: {ivy_identifier, value}

  @type eid :: Ivy.id
  @type attr_id :: Ivy.id
  @type tx_id :: Ivy.id
  @type index :: :eavt | :aevt | :avet | :vaet

  @enforce_keys [:e, :a, :v, :tx, :added?]
  defstruct [:e, :a, :v, :tx, added?: true]
  @type t :: %__MODULE__{
    e: eid,
    a: attr_id,
    v: value,
    tx: tx_id,
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

  defimpl Enumerable do
    def count(_datom), do: {:ok, 5}
    def member?(_datom, _element), do: {:error, __MODULE__}
    def slice(_datom), do: {:error, __MODULE__}
    def reduce(d, acc, reducer) do
      [d.e, d.a, d.v, d.tx, d.added?]
      |> @protocol.reduce(acc, reducer)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(datom, opts) do
      container_doc("#datom[", datom, "]", opts, &@protocol.inspect/2, break: :flex, separator: " ")
    end
  end
end
