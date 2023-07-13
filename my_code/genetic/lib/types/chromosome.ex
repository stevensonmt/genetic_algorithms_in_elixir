defmodule Types.Chromosome do
  @moduledoc false
  use Agent

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

  def start_link(genes) do
    Agent.start_link(fn -> %__MODULE__{genes: genes, size: Enum.count(genes)} end)
  end

  def get_fitness(pid) do
    Agent.get(pid, & &1.fitness)
  end

  def eval(pid, fitness) do
    c = Agent.get(pid, & &1)
    Agent.update(pid, fn -> %__MODULE__{c | fitness: fitness.(c)} end)
  end
end
