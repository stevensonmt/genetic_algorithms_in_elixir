defmodule TigerSimulation do
  @behaviour Problem
  alias Types.Chromosome

  # chromosomes = [large?, swims well?, fat?, nocturnal?, hunts large range?, thick fur?, long tail?]

  @scores %{
    tropic: [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0],
    tundra: [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]
  }

  @impl true
  def genotype do
    genes = Stream.repeatedly(fn -> Enum.random(0..1) end) |> Enum.take(8)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_fun(chromosome) do
    chromosome.genes
    |> Enum.zip(@scores.tundra)
    |> Enum.map(fn {t, s} -> t * s end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(_population, generation, _temp) do
    generation == 1000
  end
end

tiger = Genetic.run(TigerSimulation, population_size: 20, selection_rate: 0.9, mutation_rate: 0.1)
IO.write("\n")
IO.inspect(tiger)
