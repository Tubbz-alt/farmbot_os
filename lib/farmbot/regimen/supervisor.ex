defmodule Farmbot.Regimen.Supervisor do
  @moduledoc false
  use Supervisor
  use Farmbot.Logger

  @doc false
  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    children = load_from_db()
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  def add_child(regimen, time) do
    args = [regimen, time]
    opts = [restart: :transient, id: regimen.id]
    spec = worker(Farmbot.Regimen.Manager, args, opts)
    case Supervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        persist(regimen, time)
        {:ok, pid}
      err -> err
    end
  end

  def remove_child(regimen) do
    Supervisor.terminate_child(__MODULE__, regimen.id)
    Supervisor.delete_child(__MODULE__, regimen.id)
    unpersist(regimen)
  end

  defp load_from_db do
    all = Farmbot.Asset.all_persistent_regimens
    Enum.reduce(all, [], fn(pr, children) ->
      regimen = Farmbot.Asset.get_regimen_by_id(pr.regimen_id)
      if regimen do
        args = [regimen, pr.time]
        opts = [restart: :transient, id: regimen.id]
        [worker(Farmbot.Regimen.Manager, args, opts) | children]
      else
        msg = "Can't restart regimen by id: #{pr.regimen_id} because it doesn't exit."
        Logger.warn 1, msg
        children
      end
    end)
  end

  defp persist(regimen, time) do
    case Farmbot.Asset.add_persistent_regimen(regimen, time) do
      {:ok, _} -> :ok
      {:error, _} -> Logger.error 1, "Failed to persist regimen: #{regimen.name}."
    end
  end

  defp unpersist(regimen) do
    case Farmbot.Asset.delete_persistent_regimen(regimen) do
      {:ok, _} -> :ok
      {:error, _} -> Logger.error 1, "Failed to delete persistent regimen: #{regimen.name}."
    end
  end
end
