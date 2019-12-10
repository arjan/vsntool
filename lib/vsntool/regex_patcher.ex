defmodule Vsntool.RegexPatcher do
  defmacro __using__(opts) do
    filename = opts[:filename]
    regex = opts[:regex]

    quote do
      import Vsntool.Util
      import Vsntool.RegexPatcher

      def discover() do
        File.exists?(unquote(filename))
      end

      def persist_version(vsn) do
        filename = unquote(filename)
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
