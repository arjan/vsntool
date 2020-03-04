defmodule Vsntool.Plugin.ExpoJson do
  use Vsntool.JsonPatcher, file: "app.json", path: ["expo", "version"]
end
