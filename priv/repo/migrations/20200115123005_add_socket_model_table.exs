defmodule Sockets.Repo.Migrations.AddSocketModelTable do
  use Ecto.Migration

  def up do
    create table("SocketModel", primary_key: false) do
      add :id, :serial, primary_key: true
      add :user_id, :string, size: 15
      add :address, :string, size: 20
      add :port, :string, size: 15
    end

    create index("SocketModel", [:user_id])
  end

  def down do
    drop table("SocketModel")
  end
end
