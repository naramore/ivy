defmodule Ivy.Core.Anomaly do
  @moduledoc false

  @type category :: :unavailable |
                    :interrupted |
                    :incorrect |
                    :forbidden |
                    :unsupported |
                    :not_found |
                    :conflict |
                    :fault |
                    :busy
  defexception [:category, :message]
  @type t :: %__MODULE__{
    category: category,
    message: String.t
  }

  @impl Exception
  def message(%__MODULE__{category: nil, message: msg}), do: msg
  def message(%__MODULE__{category: cat, message: msg}), do: "[#{cat}] #{msg}"

  @spec new(category, String.t) :: t
  def new(category, message) do
    %__MODULE__{
      category: category,
      message: message
    }
  end
end
