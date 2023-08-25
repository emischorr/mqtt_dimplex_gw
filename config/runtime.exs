import Config

config :mqtt_dimplex_gw, :dimplex,
  host: System.get_env("DIMPLEX_HOST") || "127.0.0.1"

config :mqtt_dimplex_gw, :mqtt,
  host: System.get_env("MQTT_HOST") || "127.0.0.1",
  port: System.get_env("MQTT_PORT") || 1883,
  username: System.get_env("MQTT_USER") || nil,
  password: System.get_env("MQTT_PW") || nil,
  event_topic_namespace: System.get_env("MQTT_EVENT_TOPIC_NS") || "home/get/dimplex_gw",
  cmd_topic_namespace: System.get_env("MQTT_CMD_TOPIC_NS") || "home/set/dimplex_gw"
