defmodule A do
  @spec fred(arg :: keyword) :: [ String.t] | nil
  def fred(_), do: nil

  IO.inspect Module.definitions_in(__MODULE__)

end

IO.inspect A.__info__(:attributes)
