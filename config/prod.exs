use Mix.Config

# Here you can add different settings for production or development environment.

# Database configuration. Note that you have to create your database first.
# If postgres is not your adapter please use another.
config :sockets, Sockets.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "sockets_db",
  username: "root",
  password: "dev",
  hostname: "localhost"

config :sockets, ecto_repos: [Sockets.Repo]
