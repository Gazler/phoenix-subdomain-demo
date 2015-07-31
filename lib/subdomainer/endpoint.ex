defmodule Subdomainer.Endpoint do
  use Phoenix.Endpoint, otp_app: :subdomainer

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :subdomainer, gzip: false,
    only: ~w(css images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_subdomainer_key",
    signing_salt: "DfCjboR5"

  plug Subdomainer.Plug.Subdomain, Subdomainer.SubdomainRouter

  def handle_subdomain(conn, router) do
    case get_subdomain(conn.host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> Plug.Conn.put_private(:subdomain, subdomain)
        |> router.call({})
        |> Plug.Conn.halt
      _ -> conn
    end
  end

  defp get_subdomain(host) do
    root_host = Subdomainer.Endpoint.config(:url)[:host]
    String.replace(host, ~r/.?#{root_host}/, "")
  end

  plug :router, Subdomainer.Router

end
