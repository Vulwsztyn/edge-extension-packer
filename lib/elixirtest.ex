defmodule Elixirtest.CLI do
  def main(args \\ []) do
    args
    |> parse_args()
    |> check_args()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, _, _} =
      args
      # |> OptionParser.parse(aliases: [u: :upcase], switches: [upcase: :boolean])
      |> OptionParser.parse(aliases: [n: :name, d: :desc, a: :author, V: :vendor, v: :version, f: :files, F: :files_to_load],
      switches: [name: :string, desc: :string, author: :string, vendor: :string, version: :string, files: :string, files_to_load: :string])

    opts
  end

  defp check_args(opts) do
    errors = []
      |> check_exists(opts[:name], "Name is required")
      |> check_exists(opts[:desc], "Description is required")
      |> check_exists(opts[:author], "Author is required")
      |> check_exists(opts[:vendor], "Vendor is required")
      # |> check_version(opts[:version])
    IO.puts errors
    {:ok, opts}
  end

  defp response({status, opts}) do
    IO.puts "Status: #{status}"
    IO.puts opts
  end

  def check_exists(errors, opt, error_message) do
    case opt do
      nil -> errors ++ [error_message]
      "" -> errors ++ [error_message]
      _ -> errors
    end
  end


end
