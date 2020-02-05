defmodule Vsntool.Util do
  def vsn_branch(), do: System.get_env("VSN_BRANCH") || "master"
  def vsn_prefix(), do: System.get_env("VSN_PREFIX") || ""

  def shell(cmd) do
    :os.cmd(String.to_charlist(cmd))
    |> IO.chardata_to_string()
    |> String.trim()
  end

  def branch() do
    case shell("git rev-parse --abbrev-ref HEAD") do
      "HEAD" ->
        case shell("git log -n 1 --pretty=%d HEAD") |> IO.inspect(label: "x") do
          "(HEAD, " <> comp ->
            components =
              comp
              |> String.trim_trailing(")")
              |> String.split(", ")
              |> Enum.reject(&(match?("tag:" <> _, &1) || &1 == vsn_branch()))

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

  defp slugify(str) do
    str
    |> String.replace(vsn_prefix(), "")
    |> String.replace("_", "-")
    |> String.replace("/", "-")
    |> String.replace("HEAD", "")
  end

  def version_from_git() do
    with {:ok, version} <-
           shell("git describe --tags --abbrev=5")
           |> slugify()
           |> Version.parse() do
      br = branch()

      if br != vsn_branch() do
        pre =
          case Version.parse(br) do
            {:ok, %Version{pre: pre}} ->
              pre

            _ ->
              hash = shell("git rev-parse --short=6 HEAD")

              case slugify(br) do
                "" -> [hash]
                add -> [add, hash]
              end
          end

        {:ok, %{version | pre: pre}}
      else
        {:ok, version}
      end
    end
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
end
