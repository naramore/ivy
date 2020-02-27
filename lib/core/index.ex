defprotocol Ivy.Core.Index do
  alias Ivy.Core
  alias Ivy.Core.{Anomaly, Database, Datom}

  @spec count(t, Datom.index) :: integer
  def count(index, type)

  @spec basis_t(t) :: Core.t_value
  def basis_t(index)

  @spec entid_at(t, Database.partition, Core.time_point, keyword) :: {:ok, Core.id} | {:error, Anomaly.t}
  def entid_at(index, partition, datetime_or_t, opts \\ [])

  @spec seek_datoms(t, Datom.index, Datom.components, boolean, keyword) :: {:ok, Stream.t(Datom.t | Anomaly.t)} | {:error, Anomaly.t}
  def seek_datoms(index, type, components \\ nil, history? \\ false, opts \\ [])

  @spec add(t, [Datom.t], keyword) :: {:ok, t} | {:error, Anomaly.t}
  def add(index, datoms, opts \\ [])

  @spec excise(t, [Datom.t], keyword) :: {:ok, t} | {:error, Anomaly.t}
  def excise(index, datoms, opts \\ [])
end
