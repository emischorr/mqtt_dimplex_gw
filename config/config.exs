import Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :info

config :tesla, adapter: {Tesla.Adapter.Mint, timeout: 5_000}

config :mqtt_dimplex_gw, :device,
  update_interval: 60_000,
  query_groups: ["GROUP_01", "INPUTS"],
  filter_keys: [
    "status", "warmwater_target_temp", "warmwater_current_temp", "heating_target_temp",
    "heating_supply_temp", "heating_return_temp", "outdoor_temp"
  ]

import_config "#{config_env()}.exs"
