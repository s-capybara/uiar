defmodule Uiar.Group.SortTest do
  use ExUnit.Case

  alias Uiar.Group.Sort

  test "alphabetical within the same type" do
    line1 = {:alias, [line: 1], [{:__aliases__, [line: 1], [:Foo]}]}
    line2 = {:alias, [line: 2], [{:__aliases__, [line: 2], [:Bar]}]}

    assert Sort.eval([line1, line2]) == [line2, line1]
  end

  test "type-based sort has high priorty" do
    line1 = {:alias, [line: 1], [{:__aliases__, [line: 1], [:Foo]}]}
    line2 = {:alias, [line: 2], [{:__aliases__, [line: 2], [:Bar]}]}
    line3 = {:use, [line: 3], [{:__aliases__, [line: 3], [:Foo]}]}
    line4 = {:require, [line: 4], [{:__aliases__, [line: 4], [:Foo]}]}
    line5 = {:import, [line: 5], [{:__aliases__, [line: 5], [:Foo]}]}

    assert Sort.eval([line1, line2, line3, line4, line5]) == [line3, line5, line2, line1, line4]
  end

  test "works for nested lines" do
    line1 = {:alias, [line: 1], [{:__aliases__, [line: 1], [:Foo]}]}
    line2 = {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo, :Bar, :Baz]}]}

    line3 =
      {:alias, [line: 3],
       [
         {{:., [line: 3], [{:__aliases__, [line: 3], [:Foo]}, :{}]}, [line: 3],
          [{:__aliases__, [line: 4], [:Bar1]}, {:__aliases__, [line: 5], [:Bar2]}]}
       ]}

    assert Sort.eval([line1, line2, line3]) == [line1, line3, line2]
  end
end
