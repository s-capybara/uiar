defmodule Uiar.HelperTest do
  use ExUnit.Case

  alias Uiar.Helper

  test "line_number/1" do
    assert Helper.line_number({:alias, [line: 1], [{:__aliases__, [line: 1], [:Foo]}]}) == 1

    assert Helper.line_number(
             {:alias, [line: 3],
              [
                {{:., [line: 3], [{:__aliases__, [line: 3], [:Foo, :Bar]}, :{}]}, [line: 3],
                 [{:__aliases__, [line: 4], [:Baz1]}, {:__aliases__, [line: 5], [:Baz2]}]}
              ]}
           ) == 3
  end

  test "last_line_number/1" do
    assert Helper.last_line_number(
             {:alias, [line: 1],
              [
                {{:., [line: 1], [{:__aliases__, [line: 1], [:Foo, :Bar]}, :{}]}, [line: 1],
                 [{:__aliases__, [line: 1], [:Baz1]}, {:__aliases__, [line: 1], [:Baz2]}]}
              ]}
           ) == 1

    assert Helper.last_line_number(
             {:alias, [line: 1],
              [
                {{:., [line: 1], [{:__aliases__, [line: 1], [:Foo, :Bar]}, :{}]}, [line: 1],
                 [{:__aliases__, [line: 2], [:Baz1]}, {:__aliases__, [line: 3], [:Baz2]}]}
              ]}
           ) == 3
  end

  test "multi_line?/1" do
    refute Helper.multi_line?(
             {:alias, [line: 1],
              [
                {{:., [line: 1], [{:__aliases__, [line: 1], [:Foo, :Bar]}, :{}]}, [line: 1],
                 [{:__aliases__, [line: 1], [:Baz1]}, {:__aliases__, [line: 1], [:Baz2]}]}
              ]}
           )

    assert Helper.multi_line?(
             {:alias, [line: 1],
              [
                {{:., [line: 1], [{:__aliases__, [line: 1], [:Foo, :Bar]}, :{}]}, [line: 1],
                 [{:__aliases__, [line: 2], [:Baz1]}, {:__aliases__, [line: 3], [:Baz2]}]}
              ]}
           )
  end

  test "parent_modules/1" do
    assert Helper.parent_modules({:alias, [line: 1], [{:__aliases__, [line: 1], [:Foo]}]}) ==
             [:Foo]

    assert Helper.parent_modules(
             {:alias, [line: 2],
              [
                {{:., [line: 2], [{:__aliases__, [line: 2], [:Foo, :Bar]}, :{}]}, [line: 2],
                 [{:__aliases__, [line: 2], [:Baz1]}, {:__aliases__, [line: 2], [:Baz2]}]}
              ]}
           ) == [:Foo, :Bar]
  end

  test "child_modules_list/1" do
    assert Helper.child_modules_list(
             {:alias, [line: 1],
              [
                {{:., [line: 1], [{:__aliases__, [line: 1], [:Foo, :Bar]}, :{}]}, [line: 1],
                 [{:__aliases__, [line: 1], [:Baz1, :Baz2]}, {:__aliases__, [line: 1], [:Qux]}]}
              ]}
           ) == [[:Baz1, :Baz2], [:Qux]]
  end
end
