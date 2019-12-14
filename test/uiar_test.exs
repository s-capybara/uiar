defmodule UiarTest do
  use ExUnit.Case

  test "doesn't modify if already formatted" do
    source = """
    defmodule Example do
      use Foo

      import Foo

      alias Foo
      alias Foo.{A, B}
      alias Foo.C.D

      require Foo
    end
    """

    assert {:ok, ^source} = Uiar.format(source)
  end

  test "modifies unless formatted yet" do
    source = """
    defmodule Example do
      import Foo
      require Foo

      alias Foo.C.D

      alias Foo.{B, A}
      alias Foo

      use Foo
    end
    """

    expected = """
    defmodule Example do
      use Foo

      import Foo

      alias Foo
      alias Foo.{A, B}
      alias Foo.C.D

      require Foo
    end
    """

    assert {:ok, ^expected} = Uiar.format(source)
  end

  test "raises error if unable to parse" do
    source = """
    defmodule Example do
      import Foo
    """

    assert {:error, _} = Uiar.format(source)
  end
end
