defmodule Uiar.Finder do
  @moduledoc false

  alias Uiar.Helper

  @uiar_types Helper.types()

  @doc false
  @spec find_blocks(String.t()) :: {:ok, [Helper.block()]} | {:error, [Uiar.Error.t()]}
  def find_blocks(source) do
    with {:ok, ast} <- to_ast(source) do
      list =
        ast
        |> do_find_blocks()
        |> Enum.reject(&Enum.empty?/1)

      {:ok, list}
    end
  end

  @spec to_ast(String.t()) :: {:ok, Macro.t()} | {:error, [Uiar.Error.t()]}
  defp to_ast(source) do
    case Code.string_to_quoted(source) do
      {:ok, ast} ->
        {:ok, ast}

      {:error, {line, error, token}} ->
        message =
          "unable to parse: line=#{line}, error=#{inspect(error)}, token=#{inspect(token)}"

        {:error, [%Uiar.Error{line: line, message: message}]}
    end
  end

  @spec do_find_blocks(Macro.t() | Helper.line()) :: [Helper.block()]
  defp do_find_blocks({:__block__, _, lines}) do
    {defmodule_lines, normal_lines} = Enum.split_with(lines, &match?({:defmodule, _, _}, &1))

    this_block = Enum.filter(normal_lines, &match?({type, _, _} when type in @uiar_types, &1))
    nested_blocks = Enum.flat_map(defmodule_lines, &do_find_blocks/1)

    [this_block | nested_blocks]
  end

  defp do_find_blocks({:defmodule, _, [_, [do: line]]}) do
    do_find_blocks(line)
  end

  defp do_find_blocks({type, _, _} = line) when type in @uiar_types do
    [[line]]
  end

  defp do_find_blocks(_) do
    []
  end
end
