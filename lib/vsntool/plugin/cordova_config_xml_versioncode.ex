defmodule Vsntool.Plugin.CordovaConfigXmlVersioncode do
  use Vsntool.RegexPatcher, filename: "config.xml", regex: ~r/versionCode=\"(.*?)\"/

  def to_version_string(vsn) do
    to_string(vsn.major) <>
      String.pad_leading(to_string(vsn.minor), 2, "0") <>
      String.pad_leading(to_string(vsn.patch), 2, "0")
  end
end
