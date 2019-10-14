defmodule Vsntool.Plugin.CordovaConfigXml do
  use Vsntool.RegexPatcher, filename: "config.xml", regex: ~r/version=\"(.*?)\"/
end
