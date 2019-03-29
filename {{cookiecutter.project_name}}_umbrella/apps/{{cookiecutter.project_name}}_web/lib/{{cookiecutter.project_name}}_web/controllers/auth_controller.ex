defmodule {{cookiecutter.phoenix_module_name}}Web.AuthController do
  use {{cookiecutter.phoenix_module_name}}Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def login(conn, %{"provider" => "identity"}) do
    render(conn, "login.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case get_user(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp get_user(%{provider: :identity} = auth) do
    data = auth |> Map.fetch!(:extra) |> Map.fetch!(:raw_info)

    if data["username"] == "test" && data["password"] == "test" do
      {:ok, %{username: data["username"]}}
    else
      {:error, "Incorrect username or password."}
    end
  end
end
