defprotocol Ivy.Index do
  alias Ivy.{Anomaly, Datom}

  # [Ivy.id] | [Ivy.id, Ivy.id] | [Ivy.id, Ivy.id, Datom.value]
  # [Ivy.id, Ivy.id, Datom.value, Ivy.id]
  # [Ivy.id, Ivy.id, Datom.value, Ivy.id, boolean]
  @type components :: [term] | nil
  @type index_type :: :eavt | :aevt | :avet | :vaet

  @spec count(t, index_type) :: integer
  def count(index, type)

  @spec basis(t) :: Ivy.basis
  def basis(index)

  @spec entity_id_at(t, Ivy.ident, DateTime.t | non_neg_integer, keyword) :: {:ok, Ivy.id} | {:error, Anomaly.t}
  def entity_id_at(index, partition, datetime_or_t, opts \\ [])

  @spec seek_datoms(t, index_type, components, boolean, keyword) :: {:ok, Stream.t(Datom.t)} | {:error, Anomaly.t}
  def seek_datoms(index, type, components \\ nil, raw? \\ false, opts \\ [])

  @spec add(t, [Datom.t], keyword) :: {:ok, t} | {:error, Anomaly.t}
  def add(index, datoms, opts \\ [])

  @spec retract(t, [Datom.t], keyword) :: {:ok, t} | {:error, Anomaly.t}
  def retract(index, datoms, opts \\ [])

  @spec excise(t, [Datom.t], keyword) :: {:ok, t} | {:error, Anomaly.t}
  def excise(index, datoms, opts \\ [])
end
