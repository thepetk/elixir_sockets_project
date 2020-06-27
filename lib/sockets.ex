defmodule Sockets do
  use Application
  require Logger

  @doc """
  Listens and accepts sockets on givent port.
  It sends back a repsponse and saves incoming socket's info on DB.
  Socket has a json inside in this format:
  { 'address':'ip-address', 'port':'socket-port', 'user_id':'socket-user-id'}
  """

  # Credentials for rabbitmq
  @queue        "events"
  @host         "amqp://admin:admin@localhost:5009"

  def accept() do
    # Try to listen to a port and wait for a socket
    port = Application.get_env(:sockets, :port)
    spawn fn ->
      case :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true]) do
        {:ok, socket} ->
          Logger.info("Listening on port: #{port}")
          loop_acceptor(socket)
        {:error, reason} ->
          Logger.error("Could not listen: #{reason}")
      end
    end
  end

  defp loop_acceptor(socket) do
    # Loops in elixir are made by hand
    {:ok, client} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(Sockets.TaskSupervisor, fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    # After succesful recv, send 1 as signal and close connection
    {:ok, serialized_data} = :gen_tcp.recv(socket, 0)
    decoded_data = Jason.decode!(serialized_data)
    :gen_tcp.send(socket, "1")
    :gen_tcp.close(socket)
    # when socket is closed save its info
    save_to_db(decoded_data, serialized_data)
  end

  defp save_to_db(decoded_data, serialized_data) do
    # Try to store the event into SocketModel Table. Otherwise pass it to RabbitMQ sockets queue
    user_id = decoded_data["user_id"]
    address = decoded_data["address"]
    port = decoded_data["port"]

    params = %{
      user_id: user_id,
      address: address,
      port: port
    }

    changeset = Sockets.SocketModel.changeset(%Sockets.SocketModel{} ,params)
    try do
      Sockets.Repo.insert(changeset)
      Logger.info("Socket Info Pushed Successfully to DB. User: #{user_id}, address: #{address}, port: #{port}")
    rescue
      # Raise ArgumentError only if your data is corrupted
      error in ArgumentError -> IO.puts("Error Occured: " <> error.message)
      Ecto.ConstraintError -> update_id_seq(decoded_data, serialized_data)
      _-> publish_to_RabbitMQ(serialized_data, user_id, address, port)
    end
  end

  defp publish_to_RabbitMQ(serialized_data, user_id, address, port) do
    # Try to make a connection to rabbitMQ. On failure retry after 1 second
    case AMQP.Connection.open(@host) do
      {:ok, conn} ->
        {:ok, channel} = AMQP.Channel.open(conn)
        AMQP.Basic.publish(channel, "", @queue, serialized_data, persistent: true)
        AMQP.Connection.close(conn)
        Logger.info("Socket Info Published to RabbitMQ. User: #{user_id}, address: #{address}, port: #{port}")
      {:error, _} ->
        Logger.error("Failed to connect #{@host}. Reconnecting in 1 sec.")
        # Retry later
        :timer.sleep(1000)
        publish_to_RabbitMQ(serialized_data, user_id, address, port)
    end
  end

  defp update_id_seq(decoded_data, serialized_data) do
    # if id seq is changed outside of app it refreshes it
    Logger.error("Updating id sequence..")
    Ecto.Adapters.SQL.query(Sockets.Repo, "SELECT setval('SocketModel_id_seq', (SELECT MAX(id) from \"SocketModel\"));", [])
    save_to_db(decoded_data, serialized_data)
  end
end
