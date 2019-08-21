# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :gimme_tix,
  ecto_repos: [GimmeTix.Repo]

# Configures the endpoint
config :gimme_tix, GimmeTixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/2eMc66yK/k3EVwBE+kc88NYUyvgahOuK65EebE6xr4ElJ5kUTColNzsUW0hfBym",
  render_errors: [view: GimmeTixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GimmeTix.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
