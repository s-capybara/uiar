defmodule Uiar.FinderTest do
  use ExUnit.Case

  alias Uiar.Finder

  test "raises error if unable to parse" do
    source = """
    defmodule Example do
    alias Foo.{A, B}
    """

    assert {:error, errors} = Finder.find_blocks(source)
    assert [%Uiar.Error{line: 3}] = errors
  end

  test "finds single line" do
    source = """
    defmodule Example do
      alias Foo
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
             ]
           ] = lines
  end

  test "finds multiple lines" do
    source = """
    defmodule Example do
      alias Foo
      alias Bar
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]},
               {:alias, [line: 3], [{:__aliases__, [line: 3], [:Bar]}]}
             ]
           ] = lines
  end

  test "find nested" do
    source = """
    defmodule Example do
      alias Foo.{Bar, Bar.Bax}
      alias Qux
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {
                 :alias,
                 [line: 2],
                 [
                   {
                     {:., [line: 2], [{:__aliases__, [line: 2], [:Foo]}, :{}]},
                     [line: 2],
                     [
                       {:__aliases__, [line: 2], [:Bar]},
                       {:__aliases__, [line: 2], [:Bar, :Bax]}
                     ]
                   }
                 ]
               },
               {:alias, [line: 3], [{:__aliases__, [line: 3], [:Qux]}]}
             ]
           ] = lines
  end

  test "find nested, even when multi lines" do
    source = """
    defmodule Example do
      alias Foo.{
        Bar,
        Bar.Bax
      }

      alias Qux
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {
                 :alias,
                 [line: 2],
                 [
                   {
                     {:., [line: 2], [{:__aliases__, [line: 2], [:Foo]}, :{}]},
                     [line: 2],
                     [
                       {:__aliases__, [line: 3], [:Bar]},
                       {:__aliases__, [line: 4], [:Bar, :Bax]}
                     ]
                   }
                 ]
               },
               {:alias, [line: 7], [{:__aliases__, [line: 7], [:Qux]}]}
             ]
           ] = lines
  end

  test "finds all of uiar" do
    source = """
    defmodule Example do
      @behaviour MyBehaviour

      use Foo

      import Foo

      alias Foo

      require Foo

      @module_attribute :my_attribute

      def hello do
        :world
      end
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:use, [line: 4], [{:__aliases__, [line: 4], [:Foo]}]},
               {:import, [line: 6], [{:__aliases__, [line: 6], [:Foo]}]},
               {:alias, [line: 8], [{:__aliases__, [line: 8], [:Foo]}]},
               {:require, [line: 10], [{:__aliases__, [line: 10], [:Foo]}]}
             ]
           ] = lines
  end

  test "works for a file with no defmodule" do
    source = """
    use Mix.Config
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:use, [line: 1], [{:__aliases__, [line: 1], [:Mix, :Config]}]}
             ]
           ] = lines
  end

  test "works for a file with no uiar" do
    source = """
    defmodule Example do
      def foo() do
        :foo
      end
    end
    """

    assert {:ok, []} = Finder.find_blocks(source)
  end

  test "works for multiple defmodules" do
    source = """
    defmodule Example1 do
      alias Foo
    end

    defmodule Example2 do
      alias Bar
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
             ],
             [
               {:alias, [line: 6], [{:__aliases__, [line: 6], [:Bar]}]}
             ]
           ] = lines
  end

  test "works for nested defmodules" do
    source = """
    defmodule Example1 do
      alias Foo

      defmodule Example2 do
        alias Bar
      end
    end
    """

    assert {:ok, lines} = Finder.find_blocks(source)

    assert [
             [
               {:alias, [line: 2], [{:__aliases__, [line: 2], [:Foo]}]}
             ],
             [
               {:alias, [line: 5], [{:__aliases__, [line: 5], [:Bar]}]}
             ]
           ] = lines
  end
end
