defmodule Exred.LibraryTest do
  use ExUnit.Case
  doctest Exred.Library

  test "greets the world" do
    assert Exred.Library.hello() == :world
  end
end
