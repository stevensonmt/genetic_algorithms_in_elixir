defmodule Cargo do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..10, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_fun(chromosome) do
    profits = [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
    weights = [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
    weight_limit = 40

    potential_profits =
      profits
      |> Enum.zip_reduce(chromosome.genes, 0, fn p, g, sum -> sum + p * g end)

    over_limit? =
      chromosome.genes
      |> Enum.zip_reduce(weights, 0, fn g, w, sum -> g * w + sum end)
      |> Kernel.>(weight_limit)

    profits = if over_limit?, do: 0, else: potential_profits

    profits
  end

  @impl true
  # def terminate?(population, _generation) do
  #   Enum.max_by(population, &Cargo.fitness_fun/1).fitness == 53
  # end
  # def terminate?(_population, generation, _temperature), do: generation == 1000
  def terminate?(_population, _generation, temperature), do: temperature < 10
end

soln = Genetic.run(Cargo, population_size: 50)

IO.write("\n")
IO.inspect(soln)

weights = [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]

weight =
  soln.genes
  |> Enum.zip_reduce(weights, 0, fn g, w, sum -> sum + g * w end)

IO.write("\nWeight is: #{weight}\n")
