import Config

config :logger, :console,
  level: :info,
  format: "[$date] [$time] [$level] $message\n"
