defmodule Problem do
  @moduledoc "Provides the behaviour for genetic proglems"

  alias Types.Chromosome

  @callback genotype :: Chromosome.t()

  @callback fitness_fun(Chromosome.t()) :: number()

  @callback terminate?(Enum.t(), integer(), float()) :: boolean()
end
