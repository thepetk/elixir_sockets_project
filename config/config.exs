use Mix.Config

# configures port for project
config :sockets, port: 8080

# configures logger
config :logger, :console,
  level: :info,
  handle_otp_reports: false

# Imports dev.exs and prod.exs
import_config "#{Mix.env()}.exs"
