defmodule Elixirtest.CLI do
  def main(args \\ []) do
    args
    |> parse_args()
    |> check_args()
    # |> check_files_exist()
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
      |> check_exists(opts[:files], "Files is required")
      |> check_exists(opts[:files_to_load], "Files to load is required")
      |> check_version(opts[:version])
    files = String.split(opts[:files], ",")
    files_to_load = String.split(opts[:files_to_load], ",")
    status = cond do
      length(errors) > 0 -> :error
      true -> :ok
    end
    {status, Keyword.merge(opts, [files: files, files_to_load: files_to_load])}
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

  def check_version(errors, version) do
    cond do
      version === :nil -> errors ++ ["Version is required"]
      version =~ ~r{^\d+\.\d+\.\d+$}-> errors
      true -> errors ++ ["Version must be in the format x.y.z"]
    end
  end


end
