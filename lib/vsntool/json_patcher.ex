defmodule Vsntool.JsonPatcher do
  defmacro __using__(opts) do
    path = opts[:path]

    quote do
      import Vsntool.Util
      import Vsntool.JsonPatcher

      @behaviour Vsntool.Plugin

      @impl true
      def discover() do
        Vsntool.Plugin.opt_files(unquote(opts))
      end

      @impl true
      def persist_version(vsn, filename) do
        contents = File.read!(filename)
        path = unquote(path)
        {:ok, contents} = change_version(contents, path, vsn)
        File.write!(filename, contents)
        shell("git add '#{filename}'")
      end
    end
  end

  def change_version(contents, path, vsn) do
    vsn_el = List.last(path)
    {:ok, version_re} = Regex.compile("(\"#{vsn_el}\":\s*)\"(.*?)\"")

    case {get_in(Jason.decode!(contents), path), Regex.run(version_re, contents)} do
      {nil, _} ->
        {:error, "Version number not found in JSON at #{Enum.join(path, ".")}"}

      {version, [_, _, version]} ->
        {:ok, Regex.replace(version_re, contents, "\\1\"#{to_string(vsn)}\"")}

      {old, [_, _, new]} ->
        {:error, "Version mismatch, #{old} != #{new}"}

      {_, _} ->
        {:error, "JSON patch failed"}
    end
  end
end
