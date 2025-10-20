defmodule MqttDimplexGw.Device do
  use GenServer

  require Logger
  alias MqttDimplexGw.Mqtt
  alias MqttDimplexGw.Dimplex

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def refresh do
    GenServer.call(__MODULE__, :refresh)
  end

  # Server

  def init(_args) do
    {:ok, nil, {:continue, :init}}
  end

  def handle_continue(:init, _state) do
    config = Application.get_env(:mqtt_dimplex_gw, :device)
    {:ok, client_id} = Mqtt.connect()
    Mqtt.publish_meta(client_id)
    Process.send_after(self(), :update, 1_000)
    {:noreply, %{mqtt_client_id: client_id, config: config}}
  end

  def handle_info(:update, state) do
    update(state)
    Process.send_after(self(), :update, state.config[:update_interval])
    {:noreply, state}
  end

  def handle_call(:refresh, _from, state) do
    update(state)
    {:reply, :ok, state}
  end

  defp update(%{mqtt_client_id: client_id, config: config}) do
    with {:ok, values} <- Dimplex.groups(config[:query_groups]) do
      values
      |> Enum.filter(&(&1.key in config[:filter_keys]))
      |> Enum.map(fn %{key: key, value: value} ->
        Mqtt.publish(client_id, key, value)
      end)
    else
      {:error, {:error, %Mint.TransportError{reason: reason}}} ->
        Logger.warning("Error fetching groups endpoint: #{inspect(reason)}")
        # TODO: sent mqtt status update
    end
  end
end
