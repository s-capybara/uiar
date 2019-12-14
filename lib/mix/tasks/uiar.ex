defmodule Mix.Tasks.Uiar do
  @moduledoc """
  Formats given source codes to follow coding styles below:
    * Directives are grouped and ordered as `use`, `import`, `alias` and `require`.
    * Each group of directive is separated by an empty line.
    * Directives of the same group are ordered alphabetically.
    * If a directive handles multiple modules with `{}`, they are alphabetically ordered.

  Files can be passed by command line arguments:

    mix uiar mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"

  If no arguments are passed, they are taken from `inputs` of `.formatter.exs`.
  If `--check-formatted` option is given, it doesn't modify files but raises an error if not formatted yet.
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {opts, inputs} = OptionParser.parse!(args, strict: [check_formatted: :boolean])
    do_run(inputs, opts)
  end

  defp do_run(inputs, check_formatted: true) do
    for path <- paths(inputs) do
      source = File.read!(path)

      case Uiar.format(source) do
        {:ok, ^source} -> nil
        _ -> path
      end
    end
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        :ok

      non_formatted_paths ->
        Mix.raise("""
        The following files were not formatted on the basis of uiar rules:

        #{to_bullet_list(non_formatted_paths)}
        """)
    end
  end

  defp do_run(inputs, _opts) do
    for path <- paths(inputs) do
      source = File.read!(path)

      case Uiar.format(source) do
        {:ok, formatted} ->
          File.write!(path, formatted)

        {:error, errors} ->
          Mix.raise("Failed: path=#{path}, errors=#{inspect(errors)}")
      end
    end
  end

  defp paths([]) do
    {formatter, _} = Code.eval_file(".formatter.exs")

    case Keyword.get(formatter, :inputs, []) do
      [] -> Mix.raise("No paths found.")
      inputs -> paths(inputs)
    end
  end

  defp paths(inputs) do
    inputs
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
  end

  defp to_bullet_list(paths) do
    Enum.map_join(paths, "\n", &"  * #{&1}")
  end
end
