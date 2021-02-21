defmodule ElixirEsGrpcTest do
  use ExUnit.Case
  alias EventStore.Client
  doctest ElixirEsGrpc

  test "greets the world" do
    assert ElixirEsGrpc.hello() == :world
    ElixirEsGrpc.doit()


  end
end
