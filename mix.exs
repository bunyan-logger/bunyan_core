unless function_exported?(Bunyan.Shared.Build, :__info__, 1),
do: Code.require_file("shared_build_stuff/mix.exs")

alias Bunyan.Shared.Build

defmodule BunyanCore.MixProject do
  use Mix.Project

  def project() do
    Build.project(
      :bunyan_core,
      &deps/1,
      "The Bunyan distributed and pluggable logging system"
    )
  end

  def application() do
    [
      mod: {
        BunyanCore.Application, []
      },
    ]
  end

  def deps(_) do
    [
      bunyan:  [ bunyan_shared: ">= 0.0.0" ],
      others:  [],
    ]
  end

end
