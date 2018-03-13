defmodule Farmbot.CeleryScript.AST.Node.UnregisterGpio do
  @moduledoc false
  use Farmbot.CeleryScript.AST.Node
  allow_args [:pin_number]
  use Farmbot.Logger

  def execute(_, _, env) do
    env = mutate_env(env)
    {:error, "UnregisterGpio is depricated. Please use the `/api/pin_bindings` endpoint.", env}
  end
end
