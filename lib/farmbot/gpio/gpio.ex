defmodule Farmbot.GPIO do
  @moduledoc "Handles GPIO inputs."
  use GenStage
  use Farmbot.Logger
  alias Farmbot.Asset
  alias Asset.PinBinding

  @handler Application.get_env(:farmbot, :behaviour)[:gpio_handler]

  @doc "Register a pin number to execute sequence."
  def register_gpios(bindings) when is_list(bindings) do
    GenStage.call(__MODULE__, {:register_gpios, bindings})
  end

  @doc false
  def start_link do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end

  defmodule State do
    @moduledoc false
    defstruct [registered: %{}, handler: nil]
  end

  def init([]) do
    case @handler.start_link() do
      {:ok, handler} ->
        {:producer_consumer, struct(State, [handler: handler]), subscribe_to: [handler], dispatcher: GenStage.BroadcastDispatcher}
      err -> err
    end
  end

  defp reindex_gpios([], state), do: state

  defp reindex_gpios([%PinBinding{pin_num: pin, sequence_id: sequence_id} | rest], state) do
    case @handler.register_pin(pin) do
      :ok -> reindex_gpios(rest, %{state | registered: Map.put(state.registered, pin, sequence_id)})
      _ -> reindex_gpios(rest, state)
    end
  end

  defp unregister_all(state) do
    Enum.reduce(state.registered, state, fn(%PinBinding{pin_num: pin_num, sequence_id: sequence_id}, state) ->
      case state.registered[pin_num] do
        nil ->
          Logger.error 1, "Could not unregister #{sequence_id} from #{pin_num} " <>
          "because there currently is nothing registered to #{pin_num}"
          state
        ^sequence_id ->
          case @handler.unregister_pin(pin_num) do
            :ok ->
              Logger.success 1, "Unregistered gpio: Sequence #{sequence_id} from pin: #{pin_num}"
              %{state | registered: Map.delete(state.registered, pin_num)}
            {:error, reason} ->
              Logger.error 1, "Error unregistering gpio(#{pin_num}): #{inspect reason}"
              state
          end
        other_id ->
          Logger.warn 3, "Got request to unregister sequence #{sequence_id} from pin #{pin_num} " <>
          "But pin #{pin_num} is registered to sequence #{other_id}"
          state
      end
    end)
  end

  def handle_events(pin_triggers, _from, state) do
    t = Enum.uniq(pin_triggers)
    for {:pin_trigger, pin} <- t do
      sequence_id = state.registered[pin]
      if sequence_id do
        Logger.busy 1, "Starting Sequence: #{sequence_id} from pin: #{pin}"
        Farmbot.CeleryScript.AST.Node.Execute.execute(%{sequence_id: sequence_id}, [], struct(Macro.Env, []))
      else
        Logger.warn 3, "No sequence assosiated with: #{pin}"
      end
    end
    {:noreply, [], state}
  end

  def handle_call({:register_gpios, bindings}, _from, state) do
    new_state = reindex_gpios(bindings, unregister_all(state))
    {:reply, :ok, [{:gpio_registry, new_state.registered}], new_state}
  end

  def terminate(reason, state) do
    if state.handler do
      if Process.alive?(state.handler) do
        GenStage.stop(state.handler, reason)
      end
    end
  end
end
