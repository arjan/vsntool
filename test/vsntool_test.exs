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

    System.put_env("FORCE", "true")

    assert capture_io(fn ->
             Vsntool.main(["bump_patch"])
           end) =~ "0.0.2"

    assert capture_io(fn ->
             Vsntool.main(["last"])
           end) =~ "0.0.2"

    assert capture_io(fn ->
             Vsntool.main(["bump_minor"])
           end) =~ "0.1.0"

    assert capture_io(fn ->
             Vsntool.main(["bump_major"])
           end) =~ "1.0.0"
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
           end) =~ ~r/0\.0\.1-.{6}$/
  end

  test "vsntool on git branch with random tag added" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    Util.shell("git checkout -b feature/my-test")

    {:ok, vsn} = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."

    File.write!("testfile", "xx")
    Util.shell("git commit -am 'test commit'")
    Util.shell("git tag hello")

    File.write!("testfile", "xx2")
    Util.shell("git commit -am 'test commit'")

    {:ok, vsn} = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."
  end

  test "vsntool on git branch when checked out a single commit" do
    assert capture_io(fn ->
             Vsntool.main(["init"])
           end) =~ "Initialized git repository"

    Util.shell("git checkout -b feature/my-test")

    {:ok, vsn} = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."

    File.write!("testfile", "xx")
    Util.shell("git commit -am 'test commit'")

    commit = Util.shell("git rev-parse HEAD")
    Util.shell("git checkout #{commit}")

    {:ok, vsn} = Util.version_from_git()
    assert to_string(vsn) =~ "0.0.1-feature-my-test\."
  end
end
