defmodule Uiar.Group.Format do
  @moduledoc false

  alias Uiar.{Group, Helper}

  @typep type :: Helper.type() | nil

  @doc false
  @spec eval(Group.uiar_source_lines(), [Helper.block()]) :: Group.uiar_source_lines()
  def eval(uiar_source_lines, sorted_blocks) do
    for sorted_lines <- sorted_blocks, into: %{} do
      {
        first_line_number(sorted_lines),
        do_eval(sorted_lines, uiar_source_lines)
      }
    end
  end

  @spec first_line_number([Helper.line()]) :: pos_integer
  defp first_line_number(sorted_lines) do
    sorted_lines
    |> Enum.map(&Helper.line_number/1)
    |> Enum.min()
  end

  @spec do_eval(
          [Helper.line()],
          Group.uiar_source_lines(),
          type,
          [String.t()]
        ) :: [String.t()]
  defp do_eval(
         sorted_lines,
         uiar_source_lines,
         previous_type \\ nil,
         previous_lines \\ [],
         formatted_uiar_source_lines \\ []
       )

  defp do_eval([], _, _, _, formatted_uiar_source_lines) do
    formatted_uiar_source_lines
  end

  defp do_eval(
         [sorted_line | rest_sorted_lines],
         uiar_source_lines,
         previous_type,
         previous_source_lines,
         formatted_uiar_source_lines
       ) do
    {current_type, _, _} = sorted_line
    current_source_lines = current_source_lines(uiar_source_lines, sorted_line)

    current_formatted_uiar_source_lines =
      current_formatted_uiar_source_lines(
        current_type,
        current_source_lines,
        previous_type,
        previous_source_lines
      )

    do_eval(
      rest_sorted_lines,
      uiar_source_lines,
      current_type,
      current_source_lines,
      formatted_uiar_source_lines ++ current_formatted_uiar_source_lines
    )
  end

  @spec current_source_lines(Group.uiar_source_lines(), Helper.line()) :: [String.t()]
  defp current_source_lines(uiar_source_lines, sorted_line) do
    line_number = Helper.line_number(sorted_line)
    Map.fetch!(uiar_source_lines, line_number)
  end

  @spec current_formatted_uiar_source_lines(type, [String.t()], type, [String.t()]) ::
          [String.t()]
  defp current_formatted_uiar_source_lines(
         current_type,
         current_source_lines,
         previous_type,
         previous_source_lines
       ) do
    different_type? = current_type != previous_type and not is_nil(previous_type)
    is_current_multi_lines? = Enum.count(current_source_lines) >= 2
    is_previous_multi_lines? = Enum.count(previous_source_lines) >= 2

    if different_type? or
         (is_current_multi_lines? and not Enum.empty?(previous_source_lines)) or
         is_previous_multi_lines? do
      ["" | current_source_lines]
    else
      current_source_lines
    end
  end
end
