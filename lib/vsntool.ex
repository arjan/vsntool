defmodule Vsntool do
  import Vsntool.Util

  alias Vsntool.Plugin

  @vsntool_version Vsntool.MixProject.project()[:version]
  @options %{
    "i" => "init",
    "bm" => "bump_major",
    "bi" => "bump_minor",
    "bp" => "bump_patch",
    "br" => "bump_rc",
    "r" => "release",
    "c" => "current",
    "l" => "last",
    "h" => "help",
    "v" => "--version"
  }
  @shortcuts Map.keys(@options)
  @commands Map.values(@options)

  @kinds ~w(major minor patch)

  def main(args) do
    execute(args)
  rescue
    e in Vsntool.Flunk ->
      IO.write(:stderr, Exception.message(e) <> "\n")
      System.halt(1)
  end

  def execute([]), do: execute("current", [])

  def execute([command | args]) when command in @commands do
    execute(command, args)
  end

  def execute([shortcut | rest]) when shortcut in @shortcuts do
    execute([@options[shortcut] | rest])
  end

  def execute(_), do: execute("usage", [])

  def execute("current", []) do
    IO.puts(version_from_git())
  end

  def execute("bump_" <> kind, ["--dev"]) when kind in @kinds do
    do_bump(kind, ["dev"])
  end

  def execute("bump_" <> kind, ["--rc"]) when kind in @kinds do
    do_bump(kind, ["rc.0"])
  end

  def execute("bump_" <> kind, []) when kind in @kinds do
    do_bump(kind, [])
  end

  def execute("last", []) do
    case File.read("VERSION") do
      {:ok, vsn} ->
        IO.puts(vsn)

      _ ->
        IO.puts("*** VERSION file missing")
    end
  end

  def execute("bump_rc", []) do
    assert_release_branch()
    vsn = version_from_file()

    pre =
      case vsn.pre do
        ["dev"] ->
          ["rc", 0]

        _other ->
          n = rc_number(vsn)

          if n == nil do
            flunk("Need to be on a RC version number to bump, currently on #{vsn}")
          end

          ["rc", n + 1]
      end

    persist_version(%{vsn | pre: pre})
  end

  def execute("release", []) do
    assert_release_branch()
    vsn = version_from_file()

    if vsn.pre == [] do
      flunk("Not on a pre-release: #{vsn}")
    end

    vsn = %{vsn | pre: []}

    persist_version(vsn)
  end

  def execute("--version", []) do
    IO.puts(@vsntool_version)
  end

  def execute("help", []) do
    help_message = """
    Usage: vsntool <command> [options]
    Options:
      i,  init        Create a new VERSION file and initialize a git repository
      bm, bump_major  Bump major version (with --dev option)
      bi, bump_minor  Bump minor version (with --dev option)
      bp, bump_patch  Bump patch version (with --dev option)
      c,  current     Current version
      l,  last        Last released version
      h,  help        Display this help
      v,  --version   Display vsntool version
    """

    IO.puts(help_message)
  end

  def execute("usage", []) do
    flunk("Usage: vsntool (init|bump_major|bump_minor|bump_patch|current|last|help)")
  end

  def execute("init", []) do
    execute("init", [System.get_env("VERSION", "0.0.1")])
  end

  def execute("init", [initial_version]) do
    if File.exists?("VERSION") do
      flunk("This project already has a VERSION file")
    end

    if !File.exists?(".git") do
      IO.puts("Initialized git repository")
      shell("git init")
    end

    persist_version(Version.parse!(initial_version))
  end

  def execute(command, args) do
    flunk("Invalid args given to #{command}: #{inspect(args)}")
  end

  def persist_version(vsn) do
    case shell("git tag -l #{vsn}") do
      "" ->
        call_hook("pre_persist", [to_string(vsn)])

        File.write!("VERSION", to_string(vsn))

        Plugin.discover()
        |> Enum.map(fn {plugin, file} ->
          IO.puts("* plugin: #{inspect(plugin)} → #{file}")
          plugin.persist_version(vsn, file)
        end)

        shell("git add VERSION")
        shell("git commit -n -m 'Bump version to #{vsn}'")

        if vsn.pre != ["dev"] do
          shell("git tag -a '#{vsn_prefix()}#{vsn}' -m 'Tagged version #{vsn}'")
        end

        IO.puts("Version bump to #{vsn} OK.")

      ^vsn ->
        flunk("There is already a git tag called #{vsn}")
    end
  end

  defp do_bump(kind, pre) do
    assert_release_branch()

    vsn = version_from_file()
    git_vsn = version_from_git()

    if vsn == git_vsn && System.get_env("FORCE") != "true" do
      flunk("Current commit is already tagged (#{vsn})")
    end

    if vsn.pre != [] do
      flunk("Cannot bump when on prerelease (#{vsn})")
    end

    version = bump(String.to_atom(kind), vsn)
    version = %{version | pre: pre}

    persist_version(version)
  end

  defp assert_release_branch() do
    if branch() not in vsn_branches() do
      flunk(
        "You need to be on branch #{Enum.join(vsn_branches(), " or ")} to bump versions (currently on #{branch()})"
      )
    end
  end

  defp call_hook(name, args) do
    hookfile = Path.join([File.cwd!(), ".vsntool/hooks", name])

    if File.exists?(hookfile) do
      {output, exitcode} = System.cmd(hookfile, args)
      IO.puts(output)

      if exitcode != 0 do
        flunk("#{name} hook exited with code #{exitcode}")
      end
    end
  end
end
