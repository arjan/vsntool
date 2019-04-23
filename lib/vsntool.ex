defmodule Vsntool do
  import Vsntool.Util

  alias Vsntool.Plugin

  @vsntool_version Vsntool.MixProject.project()[:version]
  @options %{
    "i" => "init",
    "bm" => "bump_major",
    "bi" => "bump_minor",
    "bp" => "bump_patch",
    "l" => "last",
    "h" => "help",
    "v" => "--version"
  }
  @shortcuts Map.keys(@options)
  @commands Map.values(@options)

  def main([]), do: execute("current_version")

  def main([command]) when command in @commands do
    execute(command)
  end

  def main([shortcut]) when shortcut in @shortcuts do
    execute(@options[shortcut])
  end

  def main(_), do: execute("usage")

  defp execute("current_version") do
    IO.puts(version_from_git())
  end

  defp execute("bump_" <> kind) when kind in ~w(major minor patch) do
    if branch() != vsn_branch() do
      flunk(
        "You need to be on branch #{vsn_branch()} to bump versions (currently on #{branch()})"
      )
    end

    vsn = version_from_git()

    if vsn.pre == [] do
      flunk("Current commit is already tagged (#{vsn})")
    end

    bump(String.to_atom(kind), vsn)
    |> persist_version()
  end

  defp execute("init") do
    if File.exists?("VERSION") do
      flunk("This project already has a VERSION file")
    end

    if !File.exists?(".git") do
      IO.puts("Initialized git repository")
      shell("git init")
    end

    persist_version(Version.parse!("0.0.1"))
  end

  defp execute("last") do
    IO.puts(File.read!("VERSION"))
  end

  defp execute("--version") do
    IO.puts(@vsntool_version)
  end

  defp execute("help") do
    help_message = """
    Usage: vsntool [options]
    Options:
      i,  init        Create a new VERSION file and initialize a git repository
      bm, bump_major  Bump major version
      bi, bump_minor  Bump minor version
      bp, bump_patch  Bump patch version
      l,  last        Display last version
      h,  help        Display this help
      v,  --version   Display vsntool version
    """

    IO.puts(help_message)
  end

  defp execute("usage") do
    flunk("Usage: vsntool (init|bump_major|bump_minor|bump_patch|help)")
  end

  defp persist_version(vsn) do
    File.write!("VERSION", to_string(vsn))
    shell("git add VERSION")

    Plugin.discover()
    |> Enum.map(& &1.persist_version(vsn))

    shell("git commit -m 'Bump version to #{vsn}'")
    shell("git tag -a '#{vsn_prefix()}#{vsn}' -m 'Tagged version #{vsn}'")
    IO.puts("Version bump to #{vsn} OK.")
  end
end
