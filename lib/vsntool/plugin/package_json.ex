defmodule Vsntool.Plugin.PackageJson do
  use Vsntool.JsonPatcher, filename: "package.json", path: ["version"]
end
