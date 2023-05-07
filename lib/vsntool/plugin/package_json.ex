defmodule Vsntool.Plugin.PackageJson do
  use Vsntool.JsonPatcher,
    files: ["package.json", "apps/*/assets*/package.json", "assets/package.json"],
    path: ["version"]
end
