defmodule Vsntool.RegexPatcherTest do
  use ExUnit.Case

  alias Vsntool.RegexPatcher

  test "change_version" do
    contents = """
    <xml a="b">
    </xml>
    """

    {:ok, new} = RegexPatcher.change_version(contents, ~r/a=\"(.*?)\"/, "2.0")

    {:error, "Version number not found" <> _} =
      RegexPatcher.change_version(contents, ~r/fsdfdas/, "xx")
  end
end
