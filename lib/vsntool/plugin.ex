defmodule Vsntool.Plugin do
  @all [Vsntool.Plugin.PackageJson]

  def discover() do
    @all
    |> Enum.filter(& &1.discover())
  end
end
