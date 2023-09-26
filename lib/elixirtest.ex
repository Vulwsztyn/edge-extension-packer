defmodule EdgeExtensionPacker.CLI do
  def main(args \\ []) do
#    require IEx
#    IEx.pry
    args
    |> parse_args()
    |> my_bind(&check_args/1)
    |> my_bind(&check_files_exist/1)
    |> my_bind(&create_json_in_memory/1)
    |> my_bind(&create_manifest_json/1)
    |> my_bind(&get_cwd/1)
    |> my_bind(&mkdir_static_web/1)
    |> my_bind(&copy_files/1)
    |> my_bind(&create_zip/1)
    |> my_bind(&rm_manifest/1)
    |> my_bind(&rm_static_web/1)
    |> print_status()
  end

  def print_status({status, obj}) do
    case status do
      :error -> IO.puts("Error - #{obj}")
      :ok -> IO.puts("Success")
    end

    {status, obj}
  end

  defp rm_static_web(obj) do
    IO.puts("Removing static-web dir")
    cwd = obj.cwd
    rm_status = File.rm_rf(Path.join([cwd, ~c"static-web"]))

    case rm_status do
      {:ok, _} ->
        {:ok, obj}

      {:error, reason, file} ->
        {:error, "Error removing static-web - reason: #{reason} file: #{file}"}
    end
  end

  defp rm_manifest(obj) do
    IO.puts("Removing Manifest.json")
    rm_status = File.rm("Manifest.json")

    case rm_status do
      :ok -> {:ok, obj}
      {:error, error_code} -> {:error, "Error removing Manifest.json - #{error_code}"}
    end
  end

  defp create_zip(obj) do
    opts = obj.opts
    filename = "#{opts[:name]}_#{String.replace(opts[:version], ".", "_")}.zip"
    IO.puts("Creating zip #{filename}")

    {zip_status, zip_error} =
      :zip.create(filename, [
        String.to_charlist("Manifest.json"),
        String.to_charlist("static-web")
      ])

    case zip_status do
      :ok -> {:ok, obj}
      :error -> {:error, "Error creating zip - #{zip_error}"}
    end
  end

  defp copy_files(obj) do
    opts = obj.opts
    cwd = obj.cwd
    files = opts[:files]
    IO.puts("Copying files #{inspect(files)} to static-web/#{opts[:name]}")

    {status, code} =
      Enum.reduce(files, {:ok, 1}, fn file, acc ->
        case acc do
          {:ok, _} ->
            case File.copy(file, Path.join([cwd, ~c"static-web", opts[:name], file])) do
              {:ok, _} -> acc
              {:error, error_code} -> {:error, "Error copying #{file} - #{error_code}"}
            end

          {:error, _} ->
            acc
        end
      end)

    case status do
      :ok -> {:ok, obj}
      :error -> {:error, code}
    end
  end

  defp mkdir_static_web(obj) do
    IO.puts("Creating static-web dir")
    opts = obj.opts
    cwd = obj.cwd
    name = opts[:name]
    result = File.mkdir_p(Path.join([cwd, ~c"static-web", opts[:name]]))

    case result do
      :ok -> {:ok, obj}
      {:error, error_code} -> {:error, "Error creating static-web/#{name} - #{error_code}"}
    end
  end

  defp create_json_in_memory(obj) do
    IO.puts("Creating json in memory")
    opts = obj.opts

    {json_status, json_result} =
      Jason.encode(
        %{
          doClass: "ModuleManifestDO",
          version: opts[:version],
          name: opts[:name],
          vendor: opts[:vendor],
          vendorDescription: opts[:vendor_desc],
          description: opts[:desc],
          creator: opts[:author],
          creationDate: :os.system_time(:millisecond),
          preloadedScripts: opts[:files_to_load]
        },
        escape: :json,
        pretty: true
      )

    case json_status do
      :ok ->
        IO.puts("json created succesfully")
        IO.puts(json_result)
        {:ok, Map.put(obj, :json, json_result)}

      :error ->
        {:error, "Error creating json"}
    end
  end

  defp create_manifest_json(obj) do
    json = obj.json
    file_status = File.write("Manifest.json", json)

    case file_status do
      :ok -> {:ok, obj}
      {:error, error_code} -> {:error, "Error writing Manifest.json - #{error_code}"}
    end
  end

  defp check_files_exist(obj) do
    opts = obj.opts
    files_exist = Enum.all?(opts[:files], fn file -> File.exists?(file) end)
    files_to_load_exist = Enum.all?(opts[:files_to_load], fn file -> File.exists?(file) end)

    cond do
      files_exist == false -> {:error, ["Files do not exist"]}
      files_to_load_exist == false -> {:error, ["Files to load do not exist"]}
      true -> {:ok, obj}
    end
  end

  defp check_args(obj) do
    opts = obj.opts
    errors =
      []
      |> check_exists(opts[:name], "Name is required")
      |> check_exists(opts[:desc], "Description is required")
      |> check_exists(opts[:author], "Author is required")
      |> check_exists(opts[:vendor], "Vendor is required")
      |> check_exists(opts[:vendor_desc], "Vendor description is required")
      |> check_exists(opts[:files], "Files is required")
      |> check_exists(opts[:files_to_load], "Files to load is required")
      |> check_version(opts[:version])

    cond do
      length(errors) > 0 ->
        {:error, errors}

      true ->
        files = String.split(opts[:files], ",")
        files_to_load = String.split(opts[:files_to_load], ",")
        {:ok, Map.put(obj, :opts, Keyword.merge(opts, files: files, files_to_load: files_to_load))}
    end
  end

  defp parse_args(args) do
    {opts, word, _} =
      args
      # |> OptionParser.parse(aliases: [u: :upcase], switches: [upcase: :boolean])
      |> OptionParser.parse(
        aliases: [
          n: :name,
          d: :desc,
          a: :author,
          V: :vendor,
          v: :version,
          D: :vendor_desc,
          f: :files,
          F: :files_to_load,
          z: :zip_filename
        ],
        switches: [
          name: :string,
          desc: :string,
          author: :string,
          vendor: :string,
          vendor_desc: :string,
          version: :string,
          files: :string,
          files_to_load: :string,
          zip_filename: :string
        ]
      )
    {:ok, %{opts: opts}}
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
      version === nil -> errors ++ ["Version is required"]
      version =~ ~r{^\d+\.\d+\.\d+$} -> errors
      true -> errors ++ ["Version must be in the format x.y.z"]
    end
  end

  defp get_cwd(args) do
    {cwd_status, cwd_result} = File.cwd()

    case cwd_status do
      :ok -> {:ok, Map.put(args, :cwd, cwd_result)}
      :error -> {:error, "Error getting cwd"}
    end
  end

  defp my_bind({status, rest}, fun) do
    case status do
      :ok ->
        fun.(rest)

      :error ->
        {status, rest}
    end
  end
end
