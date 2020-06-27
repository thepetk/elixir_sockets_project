# creates a repo for ecto db.
defmodule Sockets.Repo do
  use Ecto.Repo,
  otp_app: :sockets,
  adapter: Ecto.Adapters.Postgres
end
