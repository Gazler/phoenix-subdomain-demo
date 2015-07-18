defmodule Subdomainer.PageController do
  use Subdomainer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
