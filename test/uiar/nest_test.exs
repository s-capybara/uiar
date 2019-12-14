defmodule Uiar.NestTest do
  use ExUnit.Case

  alias Uiar.Nest

  test "doesn't modify if there's no line" do
    source = """
    defmodule Example do
    end
    """

    assert {:ok, ^source} = Nest.format(source)
  end

  test "doesn't modify if alphabetical" do
    source = """
    defmodule Example do
      alias Foo.{A, A.B, A.C, B}
    end
    """

    assert {:ok, ^source} = Nest.format(source)
  end

  test "modifies unless alphabetical" do
    source = """
    defmodule Example do
      alias Foo1.{B, A}
      alias Foo2.{A, A.C, A.B}
      alias Foo3.{A.B, A}
    end
    """

    expected = """
    defmodule Example do
      alias Foo1.{A, B}
      alias Foo2.{A, A.B, A.C}
      alias Foo3.{A, A.B}
    end
    """

    assert {:ok, ^expected} = Nest.format(source)
  end

  test "modifies unless alphabetical, even when multi lines" do
    source = """
    defmodule Example do
      alias Foo.{
        A,
        C,
        B
      }
    end
    """

    expected = """
    defmodule Example do
      alias Foo.{
        A,
        B,
        C
      }
    end
    """

    assert {:ok, ^expected} = Nest.format(source)
  end
end
