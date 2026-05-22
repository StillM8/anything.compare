defmodule AnythingCompareWeb.PageController do
  use AnythingCompareWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
