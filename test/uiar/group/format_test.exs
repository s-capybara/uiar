defmodule Uiar.Group.FormatTest do
  use ExUnit.Case

  alias Uiar.Group.Format

  test "works for single line" do
    uiar_source_lines = %{
      2 => ["  alias Foo"],
      3 => ["  alias Bar"]
    }

    sorted_blocks = [
      [
        {:alias, [line: 3], [{:__aliases__, [line: 3], [:Bar]}]},
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
      ]
    ]

    assert Format.eval(uiar_source_lines, sorted_blocks) == %{
             2 => ["  alias Bar", "  alias Foo"]
           }
  end

  test "works for nested single line" do
    uiar_source_lines = %{
      2 => ["  alias Foo"],
      3 => ["  alias Bar.{Baz1, Baz2}"]
    }

    sorted_blocks = [
      [
        {:alias, [line: 3],
         [
           {{:., [line: 3], [{:__aliases__, [line: 3], [:Bar]}, :{}]}, [line: 3],
            [{:__aliases__, [line: 3], [:Baz1]}, {:__aliases__, [line: 3], [:Baz2]}]}
         ]},
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
      ]
    ]

    assert Format.eval(uiar_source_lines, sorted_blocks) == %{
             2 => ["  alias Bar.{Baz1, Baz2}", "  alias Foo"]
           }
  end

  test "works for nested multi line" do
    uiar_source_lines = %{
      2 => ["  alias Foo"],
      3 => [
        "  alias Bar.{",
        "    Baz1,",
        "    Baz2",
        "  }"
      ]
    }

    sorted_blocks = [
      [
        {:alias, [line: 3],
         [
           {{:., [line: 3], [{:__aliases__, [line: 3], [:Bar]}, :{}]}, [line: 3],
            [{:__aliases__, [line: 4], [:Baz1]}, {:__aliases__, [line: 5], [:Baz2]}]}
         ]},
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
      ]
    ]

    assert Format.eval(uiar_source_lines, sorted_blocks) == %{
             2 => [
               "  alias Bar.{",
               "    Baz1,",
               "    Baz2",
               "  }",
               "",
               "  alias Foo"
             ]
           }
  end

  test "adds new lines when different types" do
    uiar_source_lines = %{
      2 => ["  alias Foo"],
      3 => ["  alias Bar"],
      4 => ["  require Foo"]
    }

    sorted_blocks = [
      [
        {:alias, [line: 3], [{:__aliases__, [line: 3], [:Bar]}]},
        {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]},
        {:require, [line: 4], [{:__aliases__, [line: 4], [:Foo]}]}
      ]
    ]

    assert Format.eval(uiar_source_lines, sorted_blocks) == %{
             2 => ["  alias Bar", "  alias Foo", "", "  require Foo"]
           }
  end

  test "adds new lines when multi lines and not head" do
    uiar_source_lines = %{
      2 => [
        "  alias Foo1.{",
        "    Bar1,",
        "    Bar2",
        "  }"
      ],
      6 => [
        "  alias Foo2.{",
        "    Bar1,",
        "    Bar2",
        "  }"
      ]
    }

    sorted_blocks = [
      [
        {:alias, [line: 2],
         [
           {{:., [line: 2], [{:__aliases__, [line: 2], [:Foo1]}, :{}]}, [line: 2],
            [{:__aliases__, [line: 3], [:Bar1]}, {:__aliases__, [line: 4], [:Bar2]}]}
         ]},
        {:alias, [line: 6],
         [
           {{:., [line: 6], [{:__aliases__, [line: 6], [:Foo2]}, :{}]}, [line: 6],
            [{:__aliases__, [line: 7], [:Bar1]}, {:__aliases__, [line: 7], [:Bar2]}]}
         ]}
      ]
    ]

    assert Format.eval(uiar_source_lines, sorted_blocks) == %{
             2 => [
               "  alias Foo1.{",
               "    Bar1,",
               "    Bar2",
               "  }",
               "",
               "  alias Foo2.{",
               "    Bar1,",
               "    Bar2",
               "  }"
             ]
           }
  end
end
