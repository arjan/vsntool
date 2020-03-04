defmodule Vsntool.RegexPatcher do
  defmacro __using__(opts) do
    regex = opts[:regex]

    quote do
      import Vsntool.Util
      import Vsntool.RegexPatcher

      @behaviour Vsntool.Plugin

      @impl true
      def discover() do
        Vsntool.Plugin.opt_files(unquote(opts))
      end

      @impl true
      def persist_version(vsn, filename) do
        contents = File.read!(filename)
        regex = unquote(regex)
        replace = to_version_string(vsn)
        {:ok, contents} = change_version(contents, regex, replace)
        File.write!(filename, contents)
        shell("git add '#{filename}'")
      end

      def to_version_string(vsn) do
        to_string(vsn)
      end

      defoverridable to_version_string: 1
    end
  end

  def change_version(contents, regex, vsn) do
    case Regex.run(regex, contents) do
      [_all, oldvsn] ->
        {:ok, String.replace(contents, oldvsn, vsn)}

      _ ->
        {:error, "Version number not found in file"}
    end
  end
end
