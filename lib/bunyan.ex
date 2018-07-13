# This is a little funky...

# We want the API functions to be available in the top-level Bunyan module,
# but they are an optional dependency.
#
# So we test to see if the api has been given as a dependency in our
# host assembly, and if so we get it to inject the API functions
# into this module.

case Application.ensure_all_started(:bunyan_source_api) do
  {:ok, _} ->
    defmodule Bunyan do

      @moduledoc File.read!("README.md")

      require Bunyan.Source.Api.Injector, as: Injector
      Injector.inject_into_this_module()
    end

  _ ->
    :dont_install_macros_if_no_api_loaded
end
