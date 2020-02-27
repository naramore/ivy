defmodule Ivy.Core.Entity do
  alias Ivy.Core
  alias Ivy.Core.{Database, Datom}

  @behaviour Access

  @type value :: Datom.value | [Datom.value] | t | [t] | nil

  @enforce_keys [:db, :id]
  defstruct [:db, :id, data: %{}, opts: []]
  @type t :: %__MODULE__{
    db: Database.t,
    id: Core.id,
    data: %{optional(Core.ident) => value},
    opts: keyword
  }

  @spec new(Database.t, Core.id, keyword) :: t
  def new(db, id, opts \\ []) do
    %__MODULE__{db: db, id: id, opts: opts}
  end

  @impl Access
  def fetch(entity, key) do
    case get(entity, key) do
      :error -> :error
      {val, _} -> {:ok, val}
    end
  end

  @impl Access
  def pop(entity, key) do
    case get(entity, key) do
      :error -> {nil, entity}
      {val, ent} -> {val, %{ent | data: Map.delete(ent.data, key)}}
    end
  end

  @impl Access
  def get_and_update(entity, key, fun) do
    case get(entity, key) do
      :error -> {nil, entity}
      {val, ent} ->
        case fun.(val) do
          {val, data} -> {val, %{ent | data: data}}
          :pop -> pop(ent, key)
        end
    end
  end

  @spec get(t, Core.ident) :: {value, t} | :error
  def get(e, key) do
    with false <- Map.has_key?(e.data, key),
         id when not is_nil(id) <- Database.entid(e.db, key),
         attr when not is_nil(attr) <- Database.attribute(e.db, id),
         {:ok, stream} <- Database.datoms(e.db, :eavt, [e.id, id], e.opts),
         {:ok, val} <- Datom.collapse(stream) do
      case {attr, val} do
        {%{cardinality: :single, }, [x]} -> :ok
        {:many, }
      end
    else
      true -> {Map.get(e.data, key), e}
      _ -> :error
    end
  end

  @spec keys(t) :: {[Core.ident], t}
  def keys(entity) do
    # if not is_nil(e.keys), do: e.keys, else: below...
    # datoms(e.db, :eavt, [e.id], e.opts) |> Stream.map(&Map.get(&1, :a)) |> Stream.uniq() |> Stream.map(&Database.ident(e.db, &1)) |> Stream.reject(&is_nil/1) |> Enum.to_list()
    # + get the attribute.value_type for each key and mark if it is of type ref and single/many
    # {keys, %{e | keys: keys}}
    {[], entity}
  end

  @spec touch(t) :: t
  def touch(entity) do
    # datoms(e.db, :eavt, [e.id], e.opts) |> Datom.collapse()
    entity
  end

  @spec db(t) :: Database.t
  def db(entity), do: entity.db

  defimpl Enumerable do
    def slice(_entity), do: {:error, __MODULE__}
    def count(_entity), do: {:error, __MODULE__}
    def member?(_entity, _element), do: {:error, __MODULE__}
    def reduce(_entity, _acc, _reducer) do
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(entity, opts) do
      container_doc("#Entity<", entity.data, ">", opts, &inspector/2, separator: ",", break: :flex)
    end

    @spec inspector({atom, term}, @protocol.Opts.t) :: @protocol.t
    defp inspector({key, val}, opts) do
      concat([
        @protocol.inspect(key, opts),
        "=>",
        @protocol.inspect(val, opts)
      ])
    end
  end
end
