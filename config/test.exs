use Mix.Config

# Configure your database
config :gimme_tix, GimmeTix.Repo,
  username: "postgres",
  password: "postgres",
  database: "gimme_tix_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gimme_tix, GimmeTixWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
