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

  def main([command | _] = all) when command in @commands do
    apply(__MODULE__, :execute, all)
  end

  def main([shortcut | rest]) when shortcut in @shortcuts do
    main([@options[shortcut] | rest])
  end

  def main(_), do: execute("usage")

  def execute("current_version") do
    IO.puts(version_from_git())
  end

  def execute("bump_" <> kind) when kind in ~w(major minor patch) do
    if branch() != vsn_branch() do
      flunk(
        "You need to be on branch #{vsn_branch()} to bump versions (currently on #{branch()})"
      )
    end

    vsn = version_from_git()

    if vsn.pre == [] && System.get_env("FORCE") != "true" do
      flunk("Current commit is already tagged (#{vsn})")
    end

    bump(String.to_atom(kind), vsn)
    |> persist_version()
  end

  def execute("init") do
    execute("init", "0.0.1")
  end

  def execute("last") do
    case File.read("VERSION") do
      {:ok, vsn} ->
        IO.puts(vsn)

      _ ->
        IO.puts("*** VERSION file missing")
    end
  end

  def execute("--version") do
    IO.puts(@vsntool_version)
  end

  def execute("help") do
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

  def execute("usage") do
    flunk("Usage: vsntool (init|bump_major|bump_minor|bump_patch|help)")
  end

  def execute("init", initial_version) do
    if File.exists?("VERSION") do
      flunk("This project already has a VERSION file")
    end

    if !File.exists?(".git") do
      IO.puts("Initialized git repository")
      shell("git init")
    end

    persist_version(Version.parse!(initial_version))
  end

  def persist_version(vsn) do
    File.write!("VERSION", to_string(vsn))
    shell("git add VERSION")

    Plugin.discover()
    |> Enum.map(fn {plugin, file} ->
      IO.puts("* plugin: #{inspect(plugin)} → #{file}")
      plugin.persist_version(vsn, file)
    end)

    shell("git commit -m 'Bump version to #{vsn}'")
    shell("git tag -a '#{vsn_prefix()}#{vsn}' -m 'Tagged version #{vsn}'")
    IO.puts("Version bump to #{vsn} OK.")
  end
end
