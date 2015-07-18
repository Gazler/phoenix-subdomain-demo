defmodule Subdomainer.Subdomain.PageController do
  use Subdomainer.Web, :controller

  def index(conn, _params) do
    text(conn, "Subdomain home page")
  end

end
