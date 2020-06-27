defmodule Sockets.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sockets,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:lager, :logger, :ecto],
      mod: {Sockets.Application, []},
    ]
  end

  defp deps do
    [
      {:jason, ">= 1.1.0"},
      {:ecto_sql, "~> 3.0.0"},
      {:postgrex, ">= 0.14.0"},
      {:db_connection, ">= 0.2.5"},
      {:amqp, "~> 1.4.0"}
    ]
    end

end
