defmodule Uiar.GroupTest do
  use ExUnit.Case

  alias Uiar.Group

  test "doesn't modify if there's no uiar" do
    source = """
    defmodule Example do
    end
    """

    assert {:ok, ^source} = Group.format(source)
  end

  test "doesn't modify if properly ordered" do
    source = """
    defmodule Example do
      use Foo

      import Foo

      alias Foo

      require Foo
    end
    """

    assert {:ok, ^source} = Group.format(source)
  end

  test "doesn't modify if properly ordered, even if other statements exist" do
    source = """
    defmodule Example do
      use Foo

      import Foo

      alias Foo

      require Foo

      def foo() do
        :foo
      end
    end
    """

    assert {:ok, ^source} = Group.format(source)
  end

  test "modifies if not alphabetical" do
    source = """
    defmodule Example do
      alias Foo2
      alias Foo1
    end
    """

    expected = """
    defmodule Example do
      alias Foo1
      alias Foo2
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "modifies if not ordered as 'uiar'" do
    source = """
    defmodule Example do
      import Foo

      require Foo

      alias Foo

      use Foo
    end
    """

    expected = """
    defmodule Example do
      use Foo

      import Foo

      alias Foo

      require Foo
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "works for options" do
    source = """
    defmodule Example do
      alias Foo
      import Foo, only: [bar: 1]
    end
    """

    expected = """
    defmodule Example do
      import Foo, only: [bar: 1]

      alias Foo
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "works for nested modules" do
    source = """
    defmodule Example do
      alias Foo2.Bar.{Baz1, Baz2}
      alias Foo1.Bar.Baz.Qux
      alias Foo1.Bar.{Baz1, Baz2}
      alias Foo1.Bar
    end
    """

    expected = """
    defmodule Example do
      alias Foo1.Bar
      alias Foo1.Bar.{Baz1, Baz2}
      alias Foo1.Bar.Baz.Qux
      alias Foo2.Bar.{Baz1, Baz2}
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "works for nested modules with multi lines" do
    source = """
    defmodule Example do
      alias Foo2

      alias Foo1.Bar.{
        Baz1,
        Baz2
      }

      alias Foo3.Bar.{
        Baz1,
        Baz2
      }
    end
    """

    expected = """
    defmodule Example do
      alias Foo1.Bar.{
        Baz1,
        Baz2
      }

      alias Foo2

      alias Foo3.Bar.{
        Baz1,
        Baz2
      }
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "works for two nested modules with multi lines" do
    source = """
    defmodule Example do
      alias Foo2.Bar.{
        Qux1,
        Qux2,
        Qux3
      }

      alias Foo1.Bar.{
        Baz1,
        Baz2
      }
    end
    """

    expected = """
    defmodule Example do
      alias Foo1.Bar.{
        Baz1,
        Baz2
      }

      alias Foo2.Bar.{
        Qux1,
        Qux2,
        Qux3
      }
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "modifies if not spearated by empty lines" do
    source = """
    defmodule Example do
      use Foo1
      use Foo2
      alias Foo3
      require Foo4
    end
    """

    expected = """
    defmodule Example do
      use Foo1
      use Foo2

      alias Foo3

      require Foo4
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "modifies if spearated by an empty line within a group" do
    source = """
    defmodule Example do
      alias Foo1

      alias Foo2
    end
    """

    expected = """
    defmodule Example do
      alias Foo1
      alias Foo2
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "modifies if not spearated by an empty line and not property ordered" do
    source = """
    defmodule Example do
      alias Foo1
      use Foo2
      use Foo3
    end
    """

    expected = """
    defmodule Example do
      use Foo2
      use Foo3

      alias Foo1
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end

  test "sorts only within a block" do
    source = """
    defmodule Example1 do
      alias Foo3
      alias Foo2

      defmodule Example2 do
        alias Foo1
      end
    end
    """

    expected = """
    defmodule Example1 do
      alias Foo2
      alias Foo3

      defmodule Example2 do
        alias Foo1
      end
    end
    """

    assert {:ok, ^expected} = Group.format(source)
  end
end
