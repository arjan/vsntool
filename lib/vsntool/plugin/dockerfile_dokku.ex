defmodule Vsntool.Plugin.DockerfileDokku do
  @moduledoc """
  Patches the version in a root-level Dockerfile.dokku project.

  I have the tendency to deploy simple applications to dokku
  (http://dokku.viewdocs.io/dokku/); if so, I usually create a
  dedicated Dockerfile for dokku which dokku then uses to run the
  application from. Patching it with the version feels cleaner than
  using a :latest tag in the Dockerfile.
  """
  use Vsntool.RegexPatcher, file: "Dockerfile.dokku", regex: ~r/^FROM.*:(\d.*)$/
end
