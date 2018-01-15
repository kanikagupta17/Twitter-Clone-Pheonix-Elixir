defmodule TwitterserverTest do
  use ExUnit.Case
  doctest Twitterserver

  test "greets the world" do
    assert Twitterserver.hello() == :world
  end
end
