# simple model for ecto db
defmodule Sockets.SocketModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "SocketModel" do
    field :user_id, :string, size: 15, source: :user_id
    field :address, :string, size: 20, source: :address
    field :port, :string, size: 15, source: :port

 end
  def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:user_id, :address, :port])
  end

end
