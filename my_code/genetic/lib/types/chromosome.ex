defmodule Types.Chromosome do
  @moduledoc false

  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer(),
          id: binary()
        }

  @enforce_keys :genes
  defstruct [
    :genes,
    size: 0,
    fitness: 0,
    age: 0,
    id: Base.encode16(:crypto.strong_rand_bytes(64))
  ]
end
