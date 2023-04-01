defmodule OneMax do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..42, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 42}
  end

  @impl true
  def fitness_fun(chromosome) do
    IO.inspect(chromosome)
    fit = IO.gets("Rate from 1 to 10 ") |> String.trim()
    String.to_integer(fit)
  end

  @impl true
  # def terminate?([best | _], _generation, _temperature ), do: best.fitness == 42
  # def terminate?([_best | _], generation \\ 0, _temperature), do: generation == 100
  def terminate?([_best | _], _generation, temperature \\ 100), do: temperature < 25
  # def terminate?(population) do
  # Enum.max_by(population, &OneMax.fitness_fun/1) == 42
  # Enum.min_by(population, &OneMax.fitness_fun/1) == 0
  # avg = population |> Enum.map(&Map.get(&1, :genes)) |> Enum.map(&(Enum.sum(&1) / length(&1)))
  # avg == 21
  # end
end

soln = Genetic.run(OneMax, population_size: 100)
IO.write("\n")
IO.inspect(soln)
