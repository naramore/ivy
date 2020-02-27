defprotocol Ivy.Core.Log do
  alias Ivy.{Core, Core.Anomaly, Core.Transaction}

  @spec tx_range(t, Core.time_point | nil, Core.time_point | nil, keyword) :: {:ok, Stream.t(Transaction.t)} | {:error, Anomaly.t}
  def tx_range(log, start \\ nil, finish \\ nil, opts \\ [])
end
