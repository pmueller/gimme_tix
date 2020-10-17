defmodule GimmeTixWeb.Router do
  use GimmeTixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GimmeTixWeb do
    pipe_through :browser
    get "/", EventController, :index
    resources "/events", EventController
  end

  scope "/api/", GimmeTixWeb do
    pipe_through :api
    get "/", EventController, :index
    resources "/events", EventController
  end
end
