defmodule Uiar.Group.Sort do
  @moduledoc false

  alias Uiar.Helper

  require Uiar.Helper

  @uiar_types Helper.types()

  @doc false
  @spec eval([Helper.line()]) :: [Helper.line()]
  def eval(lines) do
    Enum.sort(lines, &sorter/2)
  end

  @spec sorter(Helper.line(), Helper.line()) :: boolean
  defp sorter({type, _, _} = left_line, {type, _, _} = right_line) do
    concat_modules(left_line) <= concat_modules(right_line)
  end

  defp sorter(left_line, right_line) do
    to_type_order(left_line) <= to_type_order(right_line)
  end

  @spec concat_modules(Helper.line()) :: String.t()
  defp concat_modules(Helper.simple_line() = line) do
    line
    |> Helper.parent_modules()
    |> Enum.join(".")
  end

  defp concat_modules(Helper.nested_line() = line) do
    line
    |> Helper.parent_modules()
    |> Kernel.++([""])
    |> Enum.join(".")
  end

  @spec to_type_order(Helper.line()) :: non_neg_integer
  defp to_type_order(line) do
    {type, _, _} = line
    Enum.find_index(@uiar_types, &(&1 == type))
  end
end
