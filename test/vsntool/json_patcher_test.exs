defmodule Vsntool.JsonPatcherTest do
  use ExUnit.Case

  alias Vsntool.JsonPatcher

  test "change_version" do
    contents = """
    {"version": "1.0"}
    """

    {:ok, new} = JsonPatcher.change_version(contents, ["version"], "2.0")
    assert "2.0" == Jason.decode!(new)["version"]

    contents = """
    {"app": {"version": "1.0"}}
    """

    {:ok, new} = JsonPatcher.change_version(contents, ["app", "version"], "2.0")
    assert "2.0" == Jason.decode!(new)["app"]["version"]

    contents = """
    {"version": "1.0"}
    """

    {:error, "Version number not found" <> _} =
      JsonPatcher.change_version(contents, ["app", "version"], "2.0")
  end
end
