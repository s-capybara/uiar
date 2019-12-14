defmodule Uiar.Group.Extract do
  @moduledoc false

  alias Uiar.{Group, Helper}

  require Uiar.Helper

  @doc false
  @spec eval([String.t()], [Helper.block()]) ::
          {Group.uiar_source_lines(), Group.line_number_source_map()}
  def eval(source_lines, blocks) do
    uiar_source_lines = %{}
    line_number_source_map = line_number_source_map(source_lines)

    blocks
    |> List.flatten()
    |> Enum.reduce({uiar_source_lines, line_number_source_map}, &do_eval/2)
  end

  @spec do_eval(
          Helper.line(),
          {Group.uiar_source_lines(), Group.line_number_source_map()}
        ) ::
          {Group.uiar_source_lines(), Group.line_number_source_map()}
  defp do_eval(
         Helper.simple_line() = line,
         {uiar_source_lines, line_number_source_map}
       ) do
    eval_single_line(line, uiar_source_lines, line_number_source_map)
  end

  defp do_eval(
         Helper.nested_line() = line,
         {uiar_source_lines, line_number_source_map}
       ) do
    if Helper.multi_line?(line) do
      eval_multi_line(line, uiar_source_lines, line_number_source_map)
    else
      eval_single_line(line, uiar_source_lines, line_number_source_map)
    end
  end

  @spec eval_single_line(
          Helper.line(),
          Group.uiar_source_lines(),
          Group.line_number_source_map()
        ) ::
          {Group.uiar_source_lines(), Group.line_number_source_map()}
  defp eval_single_line(line, uiar_source_lines, line_number_source_map) do
    line_number = Helper.line_number(line)

    {uiar_source_line, popped_line_number_source_map} =
      Map.pop(line_number_source_map, line_number)

    {
      Map.put(uiar_source_lines, line_number, [uiar_source_line]),
      popped_line_number_source_map
    }
  end

  @spec eval_multi_line(
          Helper.line(),
          Group.uiar_source_lines(),
          Group.line_number_source_map()
        ) ::
          {Group.uiar_source_lines(), Group.line_number_source_map()}
  defp eval_multi_line(line, uiar_source_lines, line_number_source_map) do
    line_number = Helper.line_number(line)
    last_line_number = Helper.last_line_number(line)

    line_numbers = Enum.to_list(line_number..(last_line_number + 1))
    uiar_source_lines_in_range = Enum.map(line_numbers, &Map.fetch!(line_number_source_map, &1))

    {
      Map.put(uiar_source_lines, line_number, uiar_source_lines_in_range),
      Map.drop(line_number_source_map, line_numbers)
    }
  end

  @spec line_number_source_map([String.t()]) :: Group.line_number_source_map()
  defp line_number_source_map(source_lines) do
    for {source_line, line_number} <- Enum.with_index(source_lines, 1), into: %{} do
      {line_number, source_line}
    end
  end
end
