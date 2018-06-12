defmodule BunyanTest do
  use ExUnit.Case
  doctest Bunyan

  test "greets the world" do
    assert Bunyan.hello() == :world
  end
end
