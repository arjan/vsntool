defmodule Vsntool.Plugin.DockerfileDokku do
  use Vsntool.RegexPatcher, file: "Dockerfile.dokku", regex: ~r/^FROM.*:(\d.*)$/
end
