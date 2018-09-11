defmodule Vsntool.Util do
  def vsn_branch(), do: System.get_env("VSN_BRANCH") || "master"
  def vsn_prefix(), do: System.get_env("VSN_PREFIX") || ""

  def shell(cmd) do
    :os.cmd(String.to_charlist(cmd))
    |> IO.chardata_to_string()
    |> String.trim()
  end

  def branch() do
    shell("git rev-parse --abbrev-ref HEAD")
  end

  def flunk(message) do
    IO.write(:stderr, message <> "\n")
    System.halt(1)
  end

  def version_from_git() do
    shell("git describe --tags")
    |> String.replace(vsn_prefix(), "")
    |> String.replace("_", "-")
    |> Version.parse!()
  end

  def bump(:major, v) do
    %Version{v | major: v.major + 1, pre: []}
  end

  def bump(:minor, v) do
    %Version{v | minor: v.minor + 1, pre: []}
  end

  def bump(:patch, v) do
    %Version{v | patch: v.patch + 1, pre: []}
  end
end
