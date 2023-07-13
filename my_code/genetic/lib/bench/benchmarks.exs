defmodule DummyProblem do
  @moduledoc false
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Stream.repeatedly(fn -> Enum.random(0..1) end) |> Enum.take(100)
    %Chromosome{genes: genes, size: 100}
  end

  @impl true
  def fitness_fun(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?(_population, generation, _temp), do: generation == 1
end

dummy_population = Genetic.initialize(&DummyProblem.genotype/0, population_size: 100)

{dummy_selected_population, _} = Genetic.select(dummy_population, selection_rate: 1.0)

Benchee.run(
  %{
    "initialize" => fn -> Genetic.initialize(&DummyProblem.genotype/0) end,
    "evaluate" => fn -> Genetic.evaluate(dummy_population, &DummyProblem.fitness_fun/1) end,
    "select" => fn -> Genetic.select(dummy_population) end,
    "crossover" => fn -> Genetic.crossover(dummy_selected_population) end,
    "mutation" => fn -> Genetic.mutation(dummy_population) end,
    "evolve" => fn -> Genetic.evolve(dummy_population, DummyProblem, 0, 0, 0) end
  },
  memory_time: 2
)
