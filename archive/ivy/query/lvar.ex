defmodule Ivy.LVar do
  alias Ivy.Package

  defstruct [:id, :name, :unique, :oname, meta: %{}]
  @type t :: %__MODULE__{
    id: term,
    name: String.t,
    unique: boolean,
    oname: term,
    meta: map()
  }

  @type new() :: t
  def new() do
    id = :erlang.monotonic_time()
    %__MODULE__{
      id: id,
      unique: true,
      name: to_string(id),
      oname: nil
    }
  end

  @spec new(term, boolean) :: t
  def new(name, unique \\ true) do
    {id, nam} = if unique do
      :erlang.monotonic_time()
      |> (&{&1, "#{name}__#{&1}"}).()
    else
      {name, to_string(name)}
    end

    %__MODULE__{
      id: id,
      name: nam,
      unique: unique,
      oname: name
    }
  end

  @spec reify_name(Package.t) :: String.t
  def reify_name(%Package{s: s}) do
    "_.#{map_size(s)}"
  end

  defimpl Ivy.Logical do
    alias Ivy.Package

    def reify(v, %Package{meta: %{reify_vars?: false}} = s) do
      Package.ext(s, v, v.name)
    end
    def reify(v, s) do
      Package.ext(s, v, @for.reify_name(s))
    end

    def occurs?(v, x, s) do
      Package.walk(s, v) == x
    end

    def build(u, %Package{s: ss} = s) do
      if Map.has_key?(ss, u) do
        s
      else
        %{s | s: Map.put(ss, u, :__ignore__)}
      end
    end
  end

  defimpl Ivy.Walkable do
    def walk(v, f) do
      f.(v)
    end
  end

  defimpl Ivy.Unifyable do
    alias Ivy.Package

    @not_found Ivy.Unifyable.Map.not_found()

    def unify(u, %@for{} = v, s) do
      Package.ext_no_check(s, u, v)
    end
    def unify(_, @not_found, _) do
      nil
    end
    def unify(u, v, s) when is_list(v) do
      Package.ext(s, u, v)
    end
    def unify(u, v, s) do
      Package.ext_no_check(s, u, v)
    end
  end
end
