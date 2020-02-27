defprotocol Ivy.Tabled do
  def reify(tabled, vars)
  def reify_var(tabled, var)
  def reuse(tabled, arg, cache, start, finish)
  def subunify(tabled, arg, ans)
end

defprotocol Ivy.Cached do
  @spec add(t, term) :: t
  def add(cached, x)

  @spec cached?(t, term) :: boolean
  def cached?(cached, x)
end

defmodule Ivy.AnswerCache do
  defstruct [ansl: [], anss: %MapSet{}, meta: %{}]
  @type t :: %__MODULE__{}

  defimpl Ivy.Cached do
    def add(cached, x) do
      %{cached | ansl: [x | cached.ansl],
                 anss: MapSet.put(cached.anss, x)}
    end

    def cached?(%{anss: anss}, x) do
      MapSet.member?(anss, x)
    end
  end
end

defmodule Ivy.SuspendedStream do
  defstruct []
  @type t :: %__MODULE__{}

  def ready?(_) do
  end
end

defimpl Ivy.Tabled, for: Ivy.Package do
  alias Ivy.{Choice, LVar, SuspendedStream, Utils}

  def reify(%@for{s: s} = tabled, vars) do
    case @for.walk(tabled, vars) do
      %LVar{} = v ->
        @for.ext_no_check(tabled, v, LVar.new(map_size(s)))
      [h | t] ->
        @protocol.reify(@protocol.reify(tabled, h), t)
      _ -> tabled
    end
  end

  def reify_var(tabled, var) do
    var = Utils.walk(tabled, var)
    Utils.walk(reify(@for.new(), var), var)
  end

  def reuse(tabled, arg, cache, start, finish) do
    start = start || cache.ansl
    finish = finish || 0
    reuse_impl(tabled, arg, cache, start, finish, start)
  end

  def subunify(tabled, arg, ans) do
    case {@for.walk(tabled, arg), ans} do
      {^ans, _} -> tabled
      {%LVar{} = arg, ans} ->
        @for.ext_no_check(tabled, arg, ans)
      {[harg | targ], [hans | tans]} ->
        @protocol.subunify(@protocol.subunify(tabled, targ, tans), harg, hans)
      _ -> tabled
    end
  end

  defp reuse_impl(tabled, argv, cache, start, finish, ansv)
    when length(ansv) == finish do
      SuspendedStream.new(cache, start, fn ->
        @protocol.reuse(tabled, argv, cache, cache.ansl, length(start))
      end)
  end
  defp reuse_impl(tabled, argv, cache, start, finish, [h | t]) do
    Choice.new(
      @protocol.subunify(tabled, argv, reify_var(tabled, h)),
      fn ->
        reuse_impl(tabled, argv, cache, start, finish, t)
      end
    )
  end
end
