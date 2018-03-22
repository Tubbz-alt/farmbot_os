defmodule Farmbot.Asset do
  @moduledoc """
  Hello Phoenix.
  """

  alias Farmbot.Asset
  alias Asset.{
    Peripheral,
    Point,
    PersistentRegimen,
    Sensor,
    Sequence,
    Regimen,
    Tool
  }
  alias Farmbot.System.ConfigStorage

  import Ecto.Query

  @doc "Gets all Regimens that should be running."
  def all_persistent_regimens do
    ConfigStorage.all(PersistentRegimen)
  end

  def add_persistent_regimen(regimen, time) do
    %PersistentRegimen{}
    |> PersistentRegimen.changeset(%{regimen_id: regimen.id, time: time})
    |> ConfigStorage.insert()
  end

  def delete_persistent_regimen(regimen) do
    pr = get_persistent_regimen(regimen)
    if pr do
      ConfigStorage.delete(pr)
    else
      {:error, "Could not find Persistent Regimen info for #{regimen.name}"}
    end
  end

  def get_persistent_regimen(regimen) do
    rid = regimen.id
    ConfigStorage.one(from pr in PersistentRegimen, where: pr.regimen_id == ^rid)
  end

  @doc "Get a Peripheral by it's id."
  def get_peripheral_by_id(peripheral_id) do
    repo().one(from p in Peripheral, where: p.id == ^peripheral_id)
  end

  @doc "Get a Sensor by it's id."
  def get_sensor_by_id(sensor_id) do
    repo().one(from s in Sensor, where: s.id == ^sensor_id)
  end

  @doc "Get a Sequence by it's id."
  def get_sequence_by_id(sequence_id) do
    repo().one(from s in Sequence, where: s.id == ^sequence_id)
  end

  @doc "Same as `get_sequence_by_id/1` but raises if no Sequence is found."
  def get_sequence_by_id!(sequence_id) do
    case get_sequence_by_id(sequence_id) do
      nil -> raise "Could not find sequence by id #{sequence_id}"
      %Sequence{} = seq -> seq
    end
  end


  @doc "Get a Point by it's id."
  def get_point_by_id(point_id) do
    repo().one(from p in Point, where: p.id == ^point_id)
  end

  @doc "Get a Tool from a Point by `tool_id`."
  def get_point_from_tool(tool_id) do
    repo().one(from p in Point, where: p.tool_id == ^tool_id)
  end

  @doc "Get a Tool by it's id."
  def get_tool_by_id(tool_id) do
    repo().one(from t in Tool, where: t.id == ^tool_id)
  end

  @doc "Get a Regimen by it's id."
  def get_regimen_by_id(regimen_id) do
    repo().one(from r in Regimen, where: r.id == ^regimen_id)
  end

  @doc "Same as `get_regimen_by_id/1` but raises if no Regimen is found."
  def get_regimen_by_id!(regimen_id) do
    case get_regimen_by_id(regimen_id) do
      nil -> raise "Could not find regimen by id #{regimen_id}"
      %Regimen{} = reg -> reg
    end
  end

  defp repo, do: Farmbot.Repo.current_repo()
end
