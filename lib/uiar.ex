defmodule Uiar do
  @moduledoc false

  alias Uiar.Error

  @doc false
  @spec format(String.t()) :: {:ok, String.t()} | {:error, [Error.t()]}
  def format(source) do
    with {:ok, source} <- Uiar.Group.format(source),
         {:ok, source} <- Uiar.Nest.format(source) do
      {:ok, source}
    end
  end
end
