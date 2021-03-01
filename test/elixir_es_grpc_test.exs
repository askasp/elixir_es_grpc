defmodule ElixirEsGrpcTest do
  use ExUnit.Case
  alias EventStore.Client
  doctest ElixirEsGrpc




  test "greets the world" do
#    ElixirEsGrpc.doit()

    :ok = ElixirEsGrpc.append_events("a_fokking_id", [%Counter.Create{id: "str"}], :any)
    :ok = ElixirEsGrpc.read_and_stay_subsrcibed()

    IO.puts "sleeping"
    :timer.sleep(5000)
    IO.puts "new sleep"
    :ok = ElixirEsGrpc.append_events("a_fokking_id", [%Counter.Create{id: "str"}], :any)
    :timer.sleep(5000)
    :ok = ElixirEsGrpc.append_events("a_fokking_id", [%Counter.Create{id: "str"}], :any)


    assert_receive({:event, %EventStore.Client.Streams.ReadResp{}}, 5000)


    

  end
end
