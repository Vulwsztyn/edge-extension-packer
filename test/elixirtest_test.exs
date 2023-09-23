defmodule ElixirtestTest do
  use ExUnit.Case
  doctest Elixirtest

  test "greets the world" do
    assert Elixirtest.hello() == :world
  end
end
