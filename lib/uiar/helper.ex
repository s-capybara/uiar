defmodule Uiar.Helper do
  @moduledoc false

  @type type :: :use | :import | :alias | :require
  @type aliases :: {:__aliases__, [line: pos_integer], [atom]}
  @type grouped_aliases :: {{:., [line: pos_integer], aliases}, [line: pos_integer], [aliases]}
  @type line :: {type, [line: pos_integer], [aliases] | [grouped_aliases]}
  @type block :: [line]

  @doc false
  defmacro simple_line() do
    quote do
      {_, _, [{:__aliases__, _, _} | _]}
    end
  end

  @doc false
  defmacro nested_line() do
    quote do
      {_, _, [{{:., _, _}, _, _}]}
    end
  end

  @doc false
  def types(), do: [:use, :import, :alias, :require]

  @doc false
  @spec line_number(line) :: pos_integer
  def line_number(line) do
    {_, [line: line_number], _} = line
    line_number
  end

  @doc false
  @spec last_line_number(line) :: pos_integer
  def last_line_number(nested_line() = line) do
    {_, _, [{{:., _, _}, _, aliases}]} = line

    aliases
    |> List.last()
    |> line_number()
  end

  @doc false
  @spec multi_line?(line) :: boolean
  def multi_line?(nested_line() = line) do
    line_number(line) != last_line_number(line)
  end

  @spec parent_modules(line) :: [atom]
  def parent_modules(simple_line() = line) do
    {_, _, [{:__aliases__, _, modules} | _]} = line
    modules
  end

  def parent_modules(nested_line() = line) do
    {_, _, [{{:., _, [{:__aliases__, _, modules} | _]}, _, _}]} = line
    modules
  end

  @spec child_modules_list(line) :: [[atom]]
  def child_modules_list(nested_line() = line) do
    {_, _, [{_, _, aliases_list}]} = line

    for aliases <- aliases_list do
      {:__aliases__, [line: _], modules} = aliases
      modules
    end
  end
end
