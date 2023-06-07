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

  def average_tiger(population) do
    [genes, fitnesses, ages] =
      population
      |> Enum.map(fn chromosome -> [chromosome.genes, chromosome.fitness, chromosome.age] end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list(&1))

    num_tigers = length(population)

    [avg_fit, avg_age] =
      [fitnesses, ages]
      |> Enum.map(fn param -> Enum.sum(param) / num_tigers end)

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&(Enum.sum(&1) / num_tigers))

    %Chromosome{genes: avg_genes, age: avg_age, fitness: avg_fit}
  end
end

tiger =
  Genetic.run(TigerSimulation,
    population_size: 20,
    selection_rate: 0.9,
    mutation_rate: 0.1,
    statistics: %{average_tiger: &TigerSimulation.average_tiger/1}
  )

IO.write("\n")
IO.inspect(tiger)

[zero, five_hundred, one_thousand] =
  [0, 500, 1000]
  |> Enum.map(&Utilities.Statistics.lookup(&1))
  |> Enum.map(&elem(&1, 1))

[:zero_gen, :fivehund_gen, :onethous_gen]
|> Enum.zip([zero, five_hundred, one_thousand])
|> Enum.each(fn {label, stat} -> IO.inspect(stat, label: label) end)

genealogy = Utilities.Genealogy.get_tree()
IO.inspect(Graph.vertices(genealogy))
