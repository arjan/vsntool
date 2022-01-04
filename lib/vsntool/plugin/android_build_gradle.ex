defmodule Vsntool.Plugin.AndroidBuildGradle do
  use Vsntool.RegexPatcher, file: "app/build.gradle", regex: ~r/versionName \"(.*?)\"/
end
