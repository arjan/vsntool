defmodule Vsntool.Plugin.CordovaPluginXml do
  use Vsntool.RegexPatcher, file: "plugin.xml", regex: ~r/<plugin.*version=\"(.*?)\"/
end
