defmodule Vsntool.Plugin.ExpoJson do
  use Vsntool.JsonPatcher, filename: "app.json", path: ["expo", "version"]
end
