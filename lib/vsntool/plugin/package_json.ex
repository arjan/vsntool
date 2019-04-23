defmodule Vsntool.Plugin.PackageJson do
  import Vsntool.Util

  def discover() do
    File.exists?(filename())
  end

  @version_re ~r/("version":\s*)"(.*?)"/

  def persist_version(vsn) do
    contents = File.read!(filename())
    contents = Regex.replace(@version_re, contents, "\\1\"#{to_string(vsn)}\"")
    File.write!(filename(), contents)
    shell("git add '#{filename()}'")
  end

  defp filename do
    File.cwd!()
    |> Path.join("package.json")
  end
end
