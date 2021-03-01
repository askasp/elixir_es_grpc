defmodule ElixirEsGrpc.Subscription do
    use GenServer
    alias EventStore.Client.Shared
    alias EventStore.Client.Streams

    def start_link([channel: channel, subscriber: sub, read_params: rp]) do
        IO.puts "got hrere at least"
        GenServer.start_link(__MODULE__, {channel, sub, rp})
    end

    def init({connection, subscriber, rp}) do
        read_params = %{
          stream: rp[:stream],
          from_event_number: rp[:from_event_number]
        }

        GenServer.cast(self(), :read_and_stay_subscribed)

        {:ok,
         %{
           subscriber: subscriber,
           connection: connection,
           read_params: read_params,
           status: :initialized,
         }}
      end

def handle_cast(:read_and_stay_subscribed, state) do
    all_opt = Streams.ReadReq.Options.AllOptions.new(all_option: {:start, Shared.Empty.new()})
    read_opt =
      Streams.ReadReq.Options.new(
        stream_option: {:all, all_opt},
        resolve_links: false,
        count_option: {:subscription, %EventStore.Client.Streams.ReadReq.Options.SubscriptionOptions{}} ,
        uuid_option: Streams.ReadReq.Options.UUIDOption.new(content: {:string, Shared.Empty.new()}),
        filter_option: {:no_filter, Shared.Empty.new()}
      )

    read_req = Streams.ReadReq.new(options: read_opt)
    {:ok, reply_enum} = Streams.Streams.Stub.read(state[:connection], read_req)
    replies = Enum.map(reply_enum, fn({:ok, reply}) ->
        IO.puts "new event"
        send(state[:subscriber],{:event, reply}) end)

    IO.puts "done"
    {:noreply, state}
 end


end

