defmodule Farmbot.GPIO.WaitForRepoTask do
  use Farmbot.Logger

  def start_link do
    Task.start_link(__MODULE__, :run, [])
  end

  @doc false
  def run do
    case Process.whereis(Farmbot.Repo.Supervisor) do
      nil ->
        Process.sleep(500)
        run()
      pid when is_pid(pid) ->
        Logger.debug 3, "Registering GPIOs."
        Farmbot.Asset.all_pin_bindings()
        |> Farmbot.GPIO.register_gpios()
        :ok
    end
  end
end
