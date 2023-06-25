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
    |> Enum.zip(@scores.tropic)
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
    population_size: 50,
    selection_rate: 0.9,
    mutation_rate: 0.1
  )

IO.write("\n")
IO.inspect(tiger)

stats = :ets.tab2list(:statistics) |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)

{:ok, cmd} =
  Gnuplot.plot(
    [
      [:set, :title, "mean fitness versus generation"],
      [:plot, "-", :with, :points]
    ],
    [stats]
  )

# , five_hundred, one_thousand] =
# , 500, 1000]
# [zero] =
#   [0]
#   |> Enum.map(&Utilities.Statistics.lookup(&1))
#   |> Enum.map(&elem(&1, 1))

# # , :fivehund_gen, :onethous_gen]
# [:zero_gen]
# # , five_hundred, one_thousand])
# |> Enum.zip([zero])
# |> Enum.each(fn {label, stat} -> IO.inspect(stat, label: label) end)

# genealogy = Utilities.Genealogy.get_tree()
# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
# {:ok, dotfile} = File.open("tiger_simulation.dot", [:write])
# :ok = IO.binwrite(dotfile, dot)
# :ok = File.close(dotfile)
# IO.inspect(Graph.vertices(genealogy))
