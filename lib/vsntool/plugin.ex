defmodule Vsntool.Plugin do
  @all [
    Vsntool.Plugin.PackageJson,
    Vsntool.Plugin.ExpoJson,
    Vsntool.Plugin.CordovaConfigXml,
    Vsntool.Plugin.CordovaConfigXmlVersioncode
  ]

  def discover() do
    @all
    |> Enum.filter(& &1.discover())
  end
end
