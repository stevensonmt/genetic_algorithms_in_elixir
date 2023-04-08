defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  alias Types.Chromosome

  @default_pop_size 100

  def initialize(genotype, opts \\ []) do
    pop_size = Keyword.get(opts, :population_size, @default_pop_size)

    Stream.repeatedly(fn -> genotype.() end)
    |> Enum.take(pop_size)
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

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/1)
    selection_rate = Keyword.get(opts, :selection_rate, 0.8)

    n =
      case round(length(population) * selection_rate) do
        x when rem(x, 2) == 0 -> x
        x -> x + 1
      end

    parents = select_fn |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    {parents, MapSet.to_list(leftover)}
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
    |> evolve(problem, 0, 0, 0, opts)
  end

  def evolve(population, problem, generation, last_max_fitness, temp, opts \\ []) do
    population = evaluate(population, &problem.fitness_fun/1, opts)
    best = hd(population)
    best_fitness = best.fitness
    temp = 0.9 * (temp + (best_fitness - last_max_fitness))
    IO.write("\rCurrent Best:#{best.fitness} at generation: #{generation}")

    case problem.terminate?(population, generation, temp) do
      true ->
        best

      :no_but_reset ->
        IO.puts("\nrestarting!\n")

        initialize(&problem.genotype/0, opts)
        |> evaluate(&problem.fitness_fun/1, opts)
        |> evolve(problem, generation + 1, last_max_fitness, 3, opts)

      _ ->
        {parents, leftover} = select(population, opts)
        children = crossover(parents, opts)

        (children ++ leftover)
        |> mutation(opts)
        |> evolve(problem, generation + 1, best_fitness, temp, opts)
    end
  end
end
