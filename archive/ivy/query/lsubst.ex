defmodule Ivy.LSubst do
  defstruct [:v]
  @type t :: %__MODULE__{
    v: term
  }
end
