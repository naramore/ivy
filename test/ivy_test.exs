defmodule IvyTest do
  use ExUnit.Case
  doctest Ivy

  test "greets the world" do
    assert Ivy.hello() == :world
  end
end
