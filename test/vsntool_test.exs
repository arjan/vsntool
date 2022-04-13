defmodule VsntoolTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Vsntool.Util

  doctest Vsntool

  alias Vsntool

  setup do
    path = Path.join([System.get_env("TMP") || "/tmp", "vsntool#{:erlang.system_time()}"])
    File.mkdir!(path)
    File.cd!(path)

    on_exit(fn ->
      File.rm_rf!(path)
    end)

    {:ok, path: path}
  end

  test "vsntool help" do
    assert capture_io(fn ->
             Vsntool.main(["help"])
           end) =~ "Usage: vsntool"
  end

  test "vsntool last" do
    assert capture_io(fn ->
             Vsntool.main(["last"])
           end) =~ "VERSION file missing"
  end

  test "vsntool init" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    assert capture_io(fn ->
             Vsntool.main([])
           end) =~ "0.0.1"

    assert capture_io(fn ->
             Vsntool.main(["last"])
           end) =~ "0.0.1"

    assert capture_io(fn ->
             Vsntool.main(["current"])
           end) == "0.0.1\n"

    File.write!("test.txt", "a")
    System.shell("git add test.txt")
    System.shell("git commit -m test")

    assert capture_io(fn ->
             Vsntool.main(["current"])
           end) =~ "0.0.1-master."

    assert capture_io(fn ->
             Vsntool.main(["bump_patch"])
           end) =~ "0.0.2"

    assert capture_io(fn ->
             Vsntool.main(["last"])
           end) == "0.0.2\n"

    System.put_env("FORCE", "true")

    assert capture_io(fn ->
             Vsntool.main(["bump_minor"])
           end) =~ "0.1.0"

    assert capture_io(fn ->
             Vsntool.main(["bump_major"])
           end) =~ "1.0.0"
  end

  test "vsntool init w/ specific version" do
    capture_io(fn ->
      Vsntool.main(["init", "1.3.0"])
    end)

    assert capture_io(fn ->
             Vsntool.main([])
           end) =~ "1.3.0"
  end

  test "bump_dev" do
    capture_io(fn ->
      Vsntool.main(["init", "1.3.0"])
    end)

    System.put_env("FORCE", "true")

    assert capture_io(fn ->
             Vsntool.main(["bump_minor", "--dev"])
           end) =~ "1.4.0-dev"

    # no tag on dev versions
    assert ["1.3.0"] == Util.shell("git tag -l") |> String.split("\n")

    assert capture_io(fn ->
             Vsntool.main(["release"])
           end) == "Version bump to 1.4.0 OK.\n"
  end

  test "bump rc" do
    capture_io(fn ->
      Vsntool.main(["init", "1.3.0"])
    end)

    System.put_env("FORCE", "true")

    assert capture_io(fn ->
             Vsntool.main(["bump_major", "--rc"])
           end) =~ "2.0.0-rc.0"

    # no tag on dev versions
    assert ["1.3.0", "2.0.0-rc.0"] == Util.shell("git tag -l") |> String.split("\n")

    assert capture_io(fn -> Vsntool.main(["bump_rc"]) end) =~ "2.0.0-rc.1"
    assert capture_io(fn -> Vsntool.main(["bump_rc"]) end) =~ "2.0.0-rc.2"

    assert capture_io(fn ->
             Vsntool.main(["release"])
           end) == "Version bump to 2.0.0 OK.\n"
  end

  test "vsntool on git branch" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    Util.shell("git checkout -b feature/my-test")

    assert capture_io(fn ->
             Vsntool.main([])
           end) =~ "0.0.1-feature-my-test\."

    File.write!("testfile", "xx")
    Util.shell("git commit -am 'test commit'")

    File.write!("testfile", "xx2")
    Util.shell("git commit -am 'test commit'")

    # detached head

    assert capture_io(fn ->
             Vsntool.main([])
           end) =~ "0.0.1-feature-my-test\."

    commit = Util.shell("git rev-parse HEAD")
    Util.shell("git checkout #{commit}")
    Util.shell("git branch -d feature/my-test")

    assert capture_io(fn ->
             Vsntool.main([])
           end) =~ ~r/0\.0\.1-.{6,7}$/
  end

  test "vsntool on git branch with random tag added" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    Util.shell("git checkout -b feature/my-test")

    vsn = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."

    File.write!("testfile", "xx")
    Util.shell("git commit -am 'test commit'")
    Util.shell("git tag hello")

    File.write!("testfile", "xx2")
    Util.shell("git commit -am 'test commit'")

    vsn = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."
  end

  test "vsntool on git branch when checked out a single commit" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    Util.shell("git checkout -b feature/my-test")

    vsn = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."

    File.write!("testfile", "xx")
    Util.shell("git commit -am 'test commit'")

    commit = Util.shell("git rev-parse HEAD")
    Util.shell("git checkout #{commit}")

    vsn = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."
  end

  test "vsntool when no names found" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    commit = Util.shell("git rev-parse HEAD")
    Util.shell("git checkout #{commit}")
    Util.shell("git branch -d master")
    Util.shell("git tag -d 0.0.1")
    vsn = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-unknown\."
  end

  test "when current tag is a valid version" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    _vsn = Util.version_from_git()
    File.write!("testfile", "xx1")
    Util.shell("git add testfile && git commit -am 'test commit'")
    File.write!("testfile", "xx2")
    Util.shell("git add testfile && git commit -am 'test commit'")

    tag = Util.version_from_git() |> to_string()

    Util.shell("git tag #{tag}")
    Util.shell("git checkout #{tag}")

    vsn = Util.version_from_git()
    assert "0.0.1-" <> _ = to_string(vsn)
  end
end
