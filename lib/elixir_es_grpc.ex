defmodule ElixirEsGrpc do
    use GenServer
    alias EventStore.Client.Shared
    alias EventStore.Client.Streams

  @moduledoc """
  Documentation for `ElixirEsGrpc`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ElixirEsGrpc.hello()
      :world

  """
  def hello do
    :world
  end

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)


  def append_events(stream_id, events, expected_version) do
      GenServer.call(__MODULE__, {:append_events, stream_id, events, expected_version})
  end

  def init(opts) do
      IO.inspect opts
      {:ok, channel} = GRPC.Stub.connect("localhost:2113")
      {:ok, channel}
  end

  def handle_call({:append_events, stream_id, events, expected_version}, _from, channel) do
    stream_id = Shared.StreamIdentifier.new(streamName: stream_id)

    expected_rev = case expected_version do
        :any -> {:any, Shared.Empty.new()}
        :no_stream -> {:no_stream, Shared.Empty.new()}
        :stream_exists -> {:stream_exists, Shared.Empty.new()}
        {:revision, nr} -> {:revision_nr}
    end

    options =
      EventStore.Client.Streams.AppendReq.Options.new(
        expected_stream_revision: expected_rev,
        stream_identifier: stream_id
      )


    stream = Streams.Streams.Stub.append(channel)
    options_request = Streams.AppendReq.new(content: {:options, options})
    GRPC.Stub.send_request(stream, options_request)

    Enum.each(events, fn event ->
        event
        |> make_proposed_message
        |> send_proposed_message(stream)
       end)

    GRPC.Stub.end_stream(stream)
    {:ok, reply_enum} = GRPC.Stub.recv(stream)
    IO.puts("writing write return")
    IO.inspect(reply_enum)
    {:reply, :ok, channel}
   end

   def send_proposed_message(message, stream) do
     GRPC.Stub.send_request(stream, message)
   end
       
   def make_proposed_message(event) do
    id = Shared.UUID.new(value: {:string, UUID.uuid1()})
    reg =
      Streams.AppendReq.ProposedMessage.new(
        data: Jason.encode!(event),
        id: id,
        metadata: %{"type" => event.__struct__
                    |> to_string
                    |> String.split(".")
                    |> List.delete_at(0)
                    |> Enum.join(),
                    "content-type" => "application/json"}
      )
    Streams.AppendReq.new(content: {:proposed_message, reg})
   end

 
  def doit do
    {:ok, _} = GenServer.start_link(ElixirEsGrpc,[connection: "rstsr"])

    all_opt = Streams.ReadReq.Options.AllOptions.new(all_option: {:start, Shared.Empty.new()})
    IO.inspect(all_opt)

    read_opt =
      Streams.ReadReq.Options.new(
        stream_option: {:all, all_opt},
        resolve_links: false,
        count_option: {:count, 1000},
        uuid_option: Streams.ReadReq.Options.UUIDOption.new(content: {:string, Shared.Empty.new()}),
        filter_option: {:no_filter, Shared.Empty.new()}
      )

    IO.inspect(read_opt)

    read_req = Streams.ReadReq.new(options: read_opt)
    #{:ok, reply_enum} = Streams.Streams.Stub.read(channel, read_req)
    #replies = Enum.map(reply_enum, fn({:ok, reply}) -> reply end)
    #IO.inspect(replies)

  end


  # def append_event(stream_id, events, expected_version) do
  #   id = Shared.UUID.new(value: {:string, UUID.uuid1()})
  #   stream_id = Shared.StreamIdentifier.new(streamName: "id1")

  #   options =
  #     EventStore.Client.Streams.AppendReq.Options.new(
  #       expected_stream_revision: {:any, Shared.Empty.new()},
  #       stream_identifier: stream_id
  #     )

  #   data = %{"key" => "value"} |> Jason.encode!()

  #   reg =
  #     Streams.AppendReq.ProposedMessage.new(
  #       data: data,
  #       id: id,
  #       metadata: %{"type" => "user_created", "content-type" => "application/json"}
  #     )

  #   message_req = Streams.AppendReq.new(content: {:proposed_message, reg})
  #   end






end
