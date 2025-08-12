defmodule ElixirAppWeb.PageController do
  use ElixirAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
