defmodule YahooFinance.Historical do
  @moduledoc """
    Contains the functions needed to pull historical stock data.
  """
  import Utils

  def run("", _, _), do: {:error, "Cannot provide empty string as argument"}

  def run(symbol, _, _) when not is_string_like(symbol),
    do: {:error, "Symbol argument must be given as string"}

  def run(_symbol, start_period, _) when not is_string_like(start_period),
    do: {:error, "Starting date must be given as string"}

  def run(_, _, end_period) when not is_string_like(end_period),
    do: {:error, "Ending date must be given as string"}

  def run(symbol, start_period, end_period) do
    [start_date, end_date] = convert_dates(start_period, end_period)

    if has_valid_dates?(start_date, end_date) do
      download(symbol, start_date, end_date)
    else
      {:error, "A date was given as an invalid format. Format as: YYYY-MM-DD"}
    end
  end

  # PRIVATE FUNCTIONS
  defp convert_dates(start_period, end_period) do
    Enum.map([start_period, end_period], &to_unix(&1))
  end

  defp to_unix(date) do
    case DateTime.from_iso8601("#{date}T10:00:00Z") do
      {:error, _} -> {:error, "Date was given as an invalid format"}
      {:ok, datetime, _} -> DateTime.to_unix(datetime)
    end
  end

  defp has_valid_dates?(start_date, end_date) do
    case [start_date, end_date] do
      [{:error, _}, _] -> false
      [_, {:error, _}] -> false
      _ -> true
    end
  end

  defp download(symbol, start_date, end_date) do
    url = download_url(symbol, start_date, end_date)
    results = request_download(url)
    handle_download(results.status_code, results.body, symbol)
  end

  defp download_url(symbol, start_date, end_date) do
    "https://query1.finance.yahoo.com/v7/finance/download/#{symbol}?period1=#{start_date}&period2=#{end_date}&interval=1d&events=history"
  end

  defp request_download(url) do
    HTTPoison.get!(url, %{})
  end

  defp handle_download(200, data, symbol) do
    {:ok, {symbol, [data]}}
  end

  defp handle_download(status_code, data, symbol) do
    handle_error(status_code, data)
  end

  defp handle_error(301, _), do: {:error, "Invalid symbol given as argument"}

  defp handle_error(401, _), do: {:error, "Issue getting cookie - Invalid Cookie"}

  defp handle_error(400, _), do: {:error, "Issue getting API - Invalid Request"}
  defp handle_error(404, _), do: {:error, "Issue getting API - Invalid Request"}

  defp handle_error(%{"finance" => info}, _), do: {:error, info["error"]["description"]}

  defp handle_error(%{"chart" => info}, _), do: {:error, info["error"]["description"]}

  defp handle_error(_, _),
    do: {:error, "Encountered an error unhandled by library. If reproducible, report as bug"}
end
