defmodule Elixirtest.CLI do
  def main(args \\ []) do
    args
    |> parse_args()
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

  defp response(opts) do
    IO.puts opts
  end
end
