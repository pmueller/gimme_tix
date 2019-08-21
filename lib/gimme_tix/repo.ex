defmodule GimmeTix.Repo do
  use Ecto.Repo,
    otp_app: :gimme_tix,
    adapter: Ecto.Adapters.Postgres
end
