defmodule Uiar.Group.Join do
  @moduledoc false

  alias Uiar.Group

  require Uiar.Helper

  @doc false
  @spec eval(Group.uiar_source_lines(), Group.line_number_source_map()) :: String.t()
  def eval(formatted_uiar_source_lines, line_number_source_map) do
    formatted_uiar_source_lines
    |> Map.merge(line_number_source_map)
    |> Enum.sort_by(fn {line_number, _source_line_or_lines} -> line_number end)
    |> Enum.map(fn {_line_number, source_line_or_lines} -> source_line_or_lines end)
    |> List.flatten()
    |> remove_duplicated_newlines()
    |> Enum.join("\n")
  end

  defp remove_duplicated_newlines(
         source_lines,
         is_previous_newline? \\ false,
         new_source_lines \\ []
       )

  @spec remove_duplicated_newlines([String.t()], boolean, [String.t()]) :: [String.t()]
  defp remove_duplicated_newlines([], _, new_source_lines) do
    Enum.reverse(new_source_lines)
  end

  defp remove_duplicated_newlines(["" | rest_source_lines], true, new_source_lines) do
    remove_duplicated_newlines(rest_source_lines, true, new_source_lines)
  end

  defp remove_duplicated_newlines(["" | rest_source_lines], false, new_source_lines) do
    remove_duplicated_newlines(rest_source_lines, true, ["" | new_source_lines])
  end

  defp remove_duplicated_newlines([source_line | rest_source_lines], true, new_source_lines) do
    if String.trim(source_line) == "end" do
      ["" | rest_new_source_lines] = new_source_lines
      remove_duplicated_newlines(rest_source_lines, false, [source_line | rest_new_source_lines])
    else
      remove_duplicated_newlines(rest_source_lines, false, [source_line | new_source_lines])
    end
  end

  defp remove_duplicated_newlines([source_line | rest_source_lines], _, new_source_lines) do
    remove_duplicated_newlines(rest_source_lines, false, [source_line | new_source_lines])
  end
end
