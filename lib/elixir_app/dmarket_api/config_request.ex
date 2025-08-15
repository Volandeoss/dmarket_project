defmodule ElixirApp.DmarketApi.ConfigRequest do
  use HTTPoison.Base

  @base_url "https://api.dmarket.com"

  def get_items(params \\ %{"limit" => "100", "currency"  => "USD", "gameId" => "a8db"}) do
    timestamp = get_timestamp()
    path = "/exchange/v1/market/items"
    query_string = URI.encode_query(params)
    full_path = path <> "?" <> query_string

    # Create unsigned string
    string_to_sign = "GET" <> full_path <> timestamp

    headers = [
      {"X-Api-Key", get_public_key()},
      {"X-Sign-Date", timestamp},
      {"X-Request-Sign", generate_signature(string_to_sign)},
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    "#{@base_url}#{full_path}"|>IO.inspect(label: "Request URL")
    |> get(headers)
    |> handle_response()
  end

  defp get_timestamp do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> to_string()
  end

  defp get_public_key do
    Application.get_env(:elixir_app, :dmarket_api)[:public_key] ||
      raise "Environment variable DMARKET_PUBLIC_KEY is missing!"
  end

  defp get_private_key do
    Application.get_env(:elixir_app, :dmarket_api)[:private_key] ||
      raise "Environment variable DMARKET_PRIVATE_KEY is missing!"
  end

  defp generate_signature(string_to_sign) do
    private_key = get_private_key()

    # Convert private key from hex to binary
    private_key_binary = Base.decode16!(private_key, case: :lower)

    # Sign the message using Ed25519
    signature = :enacl.sign_detached(string_to_sign, private_key_binary)|>IO.inspect()

    # Convert signature to lowercase hex
    Base.encode16(signature, case: :lower)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, %{status_code: status_code, body: Jason.decode!(body)}}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, %{reason: reason}}
  end
end
