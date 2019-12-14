defmodule Uiar.Group.JoinTest do
  use ExUnit.Case

  alias Uiar.Group.Join

  test "works for single line" do
    formatted_uiar_source_lines = %{
      2 => ["  alias Bar", "  alias Foo"]
    }

    line_number_source_map = %{
      1 => "defmodule do",
      4 => "end",
      5 => ""
    }

    assert Join.eval(formatted_uiar_source_lines, line_number_source_map) ==
             """
             defmodule do
               alias Bar
               alias Foo
             end
             """
  end

  test "works for duplicated newlines" do
    formatted_uiar_source_lines = %{
      2 => [
        "  alias Bar",
        "  alias Foo",
        "",
        "  require Foo"
      ]
    }

    line_number_source_map = %{
      1 => "defmodule do",
      3 => "",
      5 => "",
      7 => "end",
      8 => ""
    }

    assert Join.eval(formatted_uiar_source_lines, line_number_source_map) ==
             """
             defmodule do
               alias Bar
               alias Foo

               require Foo
             end
             """
  end
end
