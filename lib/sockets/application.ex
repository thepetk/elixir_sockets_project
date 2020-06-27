defmodule Sockets.Application do
  use Application
  require Logger
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    children = [
      supervisor(Sockets.Repo, []),
      {Task.Supervisor, name: Sockets.TaskSupervisor},
      {Task, fn -> Sockets.accept() end}
    ]
    opts = [strategy: :one_for_one, name: Sockets.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
