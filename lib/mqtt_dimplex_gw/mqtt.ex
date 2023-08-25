defmodule MqttDimplexGw.Mqtt do
  alias MqttDimplexGw.Mqtt.Handler

  @spec client :: <<_::64, _::_*8>>
  def client(), do: "dimplex_gw_#{Enum.random(1..9)}"

  @spec connect :: {:error, any} | {:ok, String.t()}
  def connect(), do: connect(client())

  @spec connect(String.t()) :: {:error, any} | {:ok, String.t()}
  def connect(client_id) do
    config = Application.get_env(:mqtt_dimplex_gw, :mqtt)

    case Tortoise.Supervisor.start_child(
      client_id: client_id,
      handler: {Handler, []},
      server: {Tortoise.Transport.Tcp, host: config[:host], port: config[:port]},
      user_name: config[:username], password: config[:password],
      subscriptions: [{"#{config[:cmd_topic_namespace]}/heatpump/+", 0}],
      will: %Tortoise.Package.Publish{topic: "#{config[:event_topic_namespace]}/status", payload: "offline", qos: 1, retain: true}
    ) do
      {:ok, _pid} ->
        {:ok, client_id}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec publish_meta(String.t()) :: :ok | {:error, :unknown_connection} | {:ok, reference}
  def publish_meta(client_id) do
    topic_ns = Application.get_env(:mqtt_dimplex_gw, :mqtt)[:event_topic_namespace]
    Tortoise.publish(client_id, "#{topic_ns}/status", "online", [qos: 0, retain: true])
  end

  @spec publish(String.t(), String.t(), binary) :: :ok | {:error, :unknown_connection} | {:ok, reference}
  def publish(client_id, key, value) when is_binary(client_id) and is_binary(key) do
    topic_ns = Application.get_env(:mqtt_dimplex_gw, :mqtt)[:event_topic_namespace]
    topic = sanitize_topic("#{topic_ns}/heatpump/#{key}")
    Tortoise.publish(client_id, topic, to_string(value), [qos: 0, retain: true])
  end

  defp sanitize_topic(topic) do
    topic |> String.downcase() |> String.replace(" ", "_")
  end
end
