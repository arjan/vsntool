defmodule Vsntool.Util do
  def vsn_branches() do
    case System.get_env("VSN_BRANCH") do
      nil -> ["main", "master"]
      branch -> [branch]
    end
  end

  def vsn_prefix(), do: System.get_env("VSN_PREFIX") || ""

  def shell(cmd) do
    :os.cmd(String.to_charlist(cmd))
    |> IO.chardata_to_string()
    |> String.trim()
  end

  def branch() do
    case shell("git rev-parse --abbrev-ref HEAD") do
      "HEAD" ->
        case shell("git log -n 1 --pretty=%d HEAD") do
          "(HEAD, " <> comp ->
            components =
              comp
              |> String.trim_trailing(")")
              |> String.split(", ")
              |> Enum.reject(&(match?("tag:" <> _, &1) || &1 in vsn_branches()))
              |> Enum.reject(&match?("refs/" <> _, &1))

            case components do
              [first | _] -> first
              [] -> ""
            end

          _ ->
            ""
        end

      v ->
        v
    end
  end

  def flunk(message) do
    IO.write(:stderr, message <> "\n")
    System.halt(1)
  end

  defp slugify("fatal:" <> _) do
    ""
  end

  defp slugify(str) do
    str
    |> String.replace(vsn_prefix(), "")
    |> String.replace(~r/[^\.A-Za-z0-9-]/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.replace("HEAD", "")
  end

  defp hash() do
    hash = shell("git rev-parse --short=6 HEAD")

    case Regex.match?(~r/^\d+$/, hash) do
      true -> hash <> "x"
      false -> hash
    end
  end

  def version_from_git() do
    if on_last_release() do
      version_from_file()
    else
      hash = hash()

      with {:ok, version} <-
             shell("git describe --tags --abbrev=5")
             |> slugify()
             |> Version.parse() do
        br = branch()

        pre =
          case Version.parse(br) do
            {:ok, %Version{pre: pre}} ->
              pre

            _ ->
              case slugify(br) do
                "" -> [hash]
                add -> [add, hash]
              end
          end

        %{version | pre: pre}
      else
        :error ->
          {:ok, version} = Version.parse(File.read!("VERSION"))
          %{version | pre: ["unknown", hash]}
      end
    end
  end

  def version_from_file() do
    Version.parse!(File.read!("VERSION"))
  end

  def bump(:major, v) do
    %Version{v | major: v.major + 1, minor: 0, patch: 0, pre: []}
  end

  def bump(:minor, v) do
    %Version{v | minor: v.minor + 1, patch: 0, pre: []}
  end

  def bump(:patch, v) do
    %Version{v | patch: v.patch + 1, pre: []}
  end

  defp on_last_release() do
    vsn = version_from_file() |> to_string()
    gitcmd = "git log -n 1 --pretty=format:'%H' "

    #    IO.inspect(vsn, label: "vsn")
    #    IO.puts(shell(gitcmd <> vsn))
    #    IO.puts(shell(gitcmd))

    branch() in vsn_branches() && shell(gitcmd <> "HEAD") == shell(gitcmd <> vsn)
  end
end
