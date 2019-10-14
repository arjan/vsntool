defmodule Vsntool.Plugin do
  @all [
    Vsntool.Plugin.PackageJson,
    Vsntool.Plugin.ExpoJson,
    Vsntool.Plugin.CordovaConfigXml
  ]

  def discover() do
    @all
    |> Enum.filter(& &1.discover())
  end
end
