defmodule Vsntool.Plugin do
  @callback discover() :: [String.t()]
  @callback persist_version(Version.t(), String.t()) :: :ok

  @all [
    Vsntool.Plugin.PackageJson,
    Vsntool.Plugin.ExpoJson,
    Vsntool.Plugin.CordovaConfigXml,
    Vsntool.Plugin.CordovaPluginXml,
    Vsntool.Plugin.CordovaConfigXmlVersioncode,
    Vsntool.Plugin.DockerfileDokku
  ]

  def discover() do
    @all
    |> Enum.map(fn plugin ->
      plugin.discover() |> Enum.map(&{plugin, &1})
    end)
    |> List.flatten()
  end

  def opt_files(opts) do
    cond do
      opts[:file] ->
        Path.wildcard(opts[:file])

      opts[:files] ->
        opts[:files]
        |> Enum.map(&Path.wildcard/1)

      true ->
        []
    end
    |> List.flatten()
    |> Enum.filter(&File.exists?/1)
  end
end
