defmodule OneMax do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..1000, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 1000}
  end

  @impl true
  def fitness_fun(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?([best | _]), do: best.fitness == 1000
end

soln = Genetic.run(OneMax, population_size: 300)
IO.write("\n")
IO.inspect(soln)
