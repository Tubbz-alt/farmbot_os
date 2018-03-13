defmodule Farmbot.CeleryScript.AST.Node.RegisterGpio do
  @moduledoc false
  use Farmbot.CeleryScript.AST.Node
  allow_args [:sequence_id, :pin_number]
  use Farmbot.Logger

  def execute(_, _, env) do
    env = mutate_env(env)
    {:error, "RegisterGpio is depricated. Please use the `/api/pin_bindings` endpoint.", env}
  end
end
