defmodule Vsntool.Plugin.ExpoVersioncode do
  use Vsntool.RegexPatcher, file: "app.json", regex: ~r/\"versionCode\": (\d+)/

  def to_version_string(vsn) do
    to_string(vsn.major) <>
      String.pad_leading(to_string(vsn.minor), 2, "0") <>
      String.pad_leading(to_string(vsn.patch), 2, "0")
  end
end
