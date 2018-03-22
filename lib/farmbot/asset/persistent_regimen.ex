defmodule Farmbot.Asset.PersistentRegimen do
  @moduledoc "A link to a regimen that should be started and supervised."

  use Ecto.Schema
  import Ecto.Changeset

  schema "persistent_regimens" do
    field :regimen_id, :integer, null: false
    field :time, :utc_datetime, null: false
    timestamps()
  end

  @required_fields [:regimen_id, :time]
  @optional_fields []

  def changeset(%__MODULE__{} = pr, params \\ %{}) do
    pr
    |> cast(params, @required_fields ++ @optional_fields)
    |> unique_constraint(:regimen_id)
    |> validate_required(@required_fields)
  end
end
