defmodule Uiar.Nest do
  @moduledoc false

  alias Uiar.Helper

  require Uiar.Helper

  @doc false
  @spec format(String.t()) :: {:ok, String.t()} | {:error, [Uiar.Error.t()]}
  def format(source) do
    with {:ok, uiar_blocks} <- Uiar.Finder.find_blocks(source) do
      source_lines = String.split(source, "\n")

      formatted =
        uiar_blocks
        |> List.flatten()
        |> Enum.reduce(source_lines, &do_format/2)
        |> Enum.join("\n")

      {:ok, formatted}
    end
  end

  @spec do_format(Helper.line(), [String.t()]) :: {:ok, String.t()} | {:error, [Uiar.Error.t()]}
  defp do_format(Helper.nested_line() = line, source_lines) do
    if Helper.multi_line?(line) do
      format_multi_line(line, source_lines)
    else
      format_single_line(line, source_lines)
    end
  end

  defp do_format(_, source_lines), do: source_lines

  @spec format_single_line(Helper.line(), [String.t()]) :: [String.t()]
  defp format_single_line(line, source_lines) do
    brace_contents =
      line
      |> Helper.child_modules_list()
      |> Enum.map(&Enum.join(&1, "."))
      |> Enum.sort()
      |> Enum.join(", ")

    index = Helper.line_number(line) - 1

    replacement =
      source_lines
      |> Enum.at(index)
      |> String.replace(~r/\{.*\}/, "{#{brace_contents}}")

    List.replace_at(source_lines, index, replacement)
  end

  @spec format_multi_line(Helper.line(), [String.t()]) :: [String.t()]
  defp format_multi_line(line, source_lines) do
    indent = " " |> List.duplicate(indent_length(source_lines, line)) |> List.to_string()

    line
    |> Helper.child_modules_list()
    |> Enum.map(&Enum.join(&1, "."))
    |> Enum.sort()
    |> format_brace_contents(indent)
    |> Enum.with_index(Helper.line_number(line))
    |> Enum.reduce(source_lines, fn {replacement, index}, source_lines ->
      List.replace_at(source_lines, index, replacement)
    end)
  end

  @spec indent_length([String.t()], Helper.line()) :: non_neg_integer
  defp indent_length(source_lines, line) do
    source_lines
    |> Enum.at(Helper.line_number(line))
    |> String.to_charlist()
    |> Enum.reduce_while(0, fn char, length ->
      case [char] do
        ' ' -> {:cont, length + 1}
        _ -> {:halt, length}
      end
    end)
  end

  @spec format_brace_contents([String.t()], String.t(), [String.t()]) :: [String.t()]
  defp format_brace_contents(source_lines, indent, formatted_source_lines \\ [])

  defp format_brace_contents([], _, formatted_source_lines),
    do: Enum.reverse(formatted_source_lines)

  defp format_brace_contents([source_line], indent, formatted_source_lines) do
    format_brace_contents([], indent, [indent <> source_line | formatted_source_lines])
  end

  defp format_brace_contents([source_line | rest_source_lines], indent, formatted_source_lines) do
    format_brace_contents(
      rest_source_lines,
      indent,
      [indent <> source_line <> "," | formatted_source_lines]
    )
  end
end
