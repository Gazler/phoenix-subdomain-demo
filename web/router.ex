defmodule Subdomainer.Router do
  use Subdomainer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Subdomainer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  def call(conn, opts) do
    case get_subdomain(conn.host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> put_private(:subdomain, subdomain)
        |> Subdomainer.SubdomainRouter.call(Subdomainer.SubdomainRouter.init(opts))
      _ -> super(conn, opts)
    end
  end

  defp get_subdomain(host) do
    root_host = Subdomainer.Endpoint.config(:url)[:host]
    String.replace(host, ~r/.?#{root_host}/, "")
  end

  # Other scopes may use custom stacks.
  # scope "/api", Subdomainer do
  #   pipe_through :api
  # end
end
