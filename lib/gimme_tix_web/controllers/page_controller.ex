defmodule GimmeTixWeb.PageController do
  use GimmeTixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
