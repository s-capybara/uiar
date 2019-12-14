defmodule Uiar.Group.ExtractTest do
  use ExUnit.Case

  alias Uiar.Group.Extract

  test "works for single lines" do
    source_lines = [
      "defmodule do",
      "  alias Foo",
      "  alias Bar",
      "end",
      ""
    ]

    blocks = [
      [
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]},
        {:alias, [line: 3], [{:__aliases__, [line: 3], [:Bar]}]}
      ]
    ]

    assert {
             %{
               2 => ["  alias Foo"],
               3 => ["  alias Bar"]
             },
             %{
               1 => "defmodule do",
               4 => "end",
               5 => ""
             }
           } = Extract.eval(source_lines, blocks)
  end

  test "works for nested lines" do
    source_lines = [
      "defmodule do",
      "  alias Foo",
      "  alias Bar.{Baz1, Baz2}",
      "end",
      ""
    ]

    blocks = [
      [
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]},
        {:alias, [line: 3],
         [
           {{:., [line: 3], [{:__aliases__, [line: 3], [:Bar]}, :{}]}, [line: 3],
            [{:__aliases__, [line: 3], [:Baz1]}, {:__aliases__, [line: 3], [:Baz2]}]}
         ]}
      ]
    ]

    assert {
             %{
               2 => ["  alias Foo"],
               3 => ["  alias Bar.{Baz1, Baz2}"]
             },
             %{
               1 => "defmodule do",
               4 => "end",
               5 => ""
             }
           } = Extract.eval(source_lines, blocks)
  end

  test "works for nested multi lines" do
    source_lines = [
      "defmodule do",
      "  alias Foo",
      "  alias Bar.{",
      "    Baz1,",
      "    Baz2",
      "  }",
      "end",
      ""
    ]

    blocks = [
      [
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]},
        {:alias, [line: 3],
         [
           {{:., [line: 3], [{:__aliases__, [line: 3], [:Bar]}, :{}]}, [line: 3],
            [{:__aliases__, [line: 4], [:Baz1]}, {:__aliases__, [line: 5], [:Baz2]}]}
         ]}
      ]
    ]

    assert {
             %{
               2 => ["  alias Foo"],
               3 => [
                 "  alias Bar.{",
                 "    Baz1,",
                 "    Baz2",
                 "  }"
               ]
             },
             %{
               1 => "defmodule do",
               7 => "end",
               8 => ""
             }
           } = Extract.eval(source_lines, blocks)
  end
end
