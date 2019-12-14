defmodule Uiar.Error do
  @moduledoc """
  Provides error details.
  """

  defstruct [
    :line,
    :message
  ]

  @type t :: %__MODULE__{
          line: pos_integer,
          message: String.t()
        }
end
