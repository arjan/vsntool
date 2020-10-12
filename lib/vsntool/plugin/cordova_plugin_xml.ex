defmodule Vsntool.Plugin.CordovaPluginXml do
  use Vsntool.RegexPatcher, file: "plugin.xml", regex: ~r/version=\"(.*?)\"/
end
