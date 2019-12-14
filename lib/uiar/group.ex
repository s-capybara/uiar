defmodule Uiar.Group do
  @moduledoc false

  alias Uiar.{Group, Helper}

  require Uiar.Helper

  @type uiar_source_lines :: %{pos_integer => [String.t()]}
  @type line_number_source_map :: %{pos_integer => String.t()}

  @doc false
  @spec format(String.t()) :: {:ok, String.t()} | {:error, [Uiar.Error.t()]}
  def format(source) do
    with {:ok, blocks} <- Uiar.Finder.find_blocks(source) do
      if Enum.empty?(blocks) do
        {:ok, source}
      else
        {:ok, do_format(source, blocks)}
      end
    end
  end

  @spec do_format(String.t(), [Helper.block()]) :: String.t()
  defp do_format(source, blocks) do
    source_lines = String.split(source, "\n")
    sorted_blocks = Enum.map(blocks, &Group.Sort.eval/1)
    {uiar_source_lines, line_number_source_map} = Group.Extract.eval(source_lines, blocks)
    formatted_uiar_source_lines = Group.Format.eval(uiar_source_lines, sorted_blocks)
    Group.Join.eval(formatted_uiar_source_lines, line_number_source_map)
  end
end
