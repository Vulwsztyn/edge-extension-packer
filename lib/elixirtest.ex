defmodule EdgeExtensionPacker.CLI do
  def main(args \\ []) do
    args
    |> parse_args()
    |> check_args()
    |> check_files_exist()
    |> response()
  end

  defp response({status, opts}) do
    # TODO check status
    {json_status, json_result} = Jason.encode(
      %{
        doClass: "ModuleManifestDO",
        version: opts[:version],
        name: opts[:name],
        vendor: opts[:vendor],
        vendorDescription: opts[:vendor_desc],
        description: opts[:desc],
        creator: opts[:author],
        creationDate: :os.system_time(:millisecond),
        preloadedScripts: opts[:files_to_load],
      }, escape: :json, pretty: true
    )

    file_status = File.write("Manifest.json", json_result)

    {cwd_status, cwd_result} = File.cwd()
    File.mkdir(Path.join([cwd_result, 'static-web']))
    File.mkdir(Path.join([cwd_result, 'static-web', opts[:name]]))

    Enum.each(opts[:files], fn file -> File.copy(Path.join([cwd_result, file]), Path.join([cwd_result, 'static-web', opts[:name], file])) end)

    mani = String.to_charlist "Manifest.json"
    filename = "#{opts[:name]}_#{String.replace(opts[:version], ".", "_")}.zip"
    IO.puts filename
    {zip_status, zip_error} = :zip.create(filename, [String.to_charlist("Manifest.json"), String.to_charlist("static-web")])

    File.rm("Manifest.json")
    File.rm_rf(Path.join([cwd_result, 'static-web']))
    IO.puts "json_status #{json_status}"
    IO.puts "json_result #{json_result}"
    IO.puts "file_status #{file_status}"
    IO.puts "cwd_status #{cwd_status}"
    IO.puts "cwd_result #{cwd_result}"
    IO.puts "zip_status #{zip_status}"
    IO.puts "zip_error #{zip_error}"
  end

  defp check_files_exist({status, opts}) do
  case status do
    :ok ->
      files_exist = Enum.all?(opts[:files], fn file -> File.exists?(file) end)
      files_to_load_exist = Enum.all?(opts[:files_to_load], fn file -> File.exists?(file) end)
      cond do
        files_exist == false -> {:error, ["Files do not exist"]}
        files_to_load_exist == false -> {:error, ["Files to load do not exist"]}
        true -> {:ok, opts}
    end
    :error ->
      {status, opts}
  end
  end


  defp check_args(opts) do
    errors = []
      |> check_exists(opts[:name], "Name is required")
      |> check_exists(opts[:desc], "Description is required")
      |> check_exists(opts[:author], "Author is required")
      |> check_exists(opts[:vendor], "Vendor is required")
      |> check_exists(opts[:vendor_desc], "Vendor description is required")
      |> check_exists(opts[:files], "Files is required")
      |> check_exists(opts[:files_to_load], "Files to load is required")
      |> check_version(opts[:version])
    cond do
      length(errors) > 0 -> {:error, errors}
      true ->
        files = String.split(opts[:files], ",")
        files_to_load = String.split(opts[:files_to_load], ",")
        {:ok, Keyword.merge(opts, [files: files, files_to_load: files_to_load])}
    end
  end

  defp parse_args(args) do
    {opts, _, _} =
      args
      # |> OptionParser.parse(aliases: [u: :upcase], switches: [upcase: :boolean])
      |> OptionParser.parse(aliases: [n: :name, d: :desc, a: :author, V: :vendor, v: :version, D: :vendor_desc, f: :files, F: :files_to_load],
      switches: [name: :string, desc: :string, author: :string, vendor: :string, vendor_desc: :string, version: :string, files: :string, files_to_load: :string])

    opts
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
