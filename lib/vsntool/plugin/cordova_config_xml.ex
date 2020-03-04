defmodule Vsntool.Plugin.CordovaConfigXml do
  use Vsntool.RegexPatcher, file: "config.xml", regex: ~r/version=\"(.*?)\"/
end
