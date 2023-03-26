defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  alias Types.Chromosome

  @default_pop_size 100

  def initialize(genotype, opts \\ []) do
    pop_size = Keyword.get(opts, :population_size, @default_pop_size)
    for _ <- 1..pop_size, do: genotype.()
  end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  def select(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def crossover(population, _opts \\ []) do
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        # passing length of chromosome to :rand.uniform/1 prevents overflow 
        # and allows any size chromosome to be used
        cx_point = :rand.uniform(length(p1.genes))
        {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
        {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
        [c1, c2 | acc]
      end
    )
  end

  def mutation(population, opts \\ []) do
    mut_rate = Keyword.get(opts, :mutation_rate, 0.05)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mut_rate do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    population
    |> evolve(problem, opts)
  end

  def evolve(population, problem, opts \\ []) do
    population = evaluate(population, &problem.fitness_fun/1, opts)
    best = hd(population)
    IO.write("\rCurrent Best:#{best.fitness}")

    if problem.terminate?(population) do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, opts)
    end
  end
end