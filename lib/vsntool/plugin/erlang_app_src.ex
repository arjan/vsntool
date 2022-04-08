defmodule Vsntool.Plugin.ErlangAppSrc do
  use Vsntool.RegexPatcher, files: ["src/*.app.src"], regex: ~r/\{vsn, \"(.*?)\"/
end
