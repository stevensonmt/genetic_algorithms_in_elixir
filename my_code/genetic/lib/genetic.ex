defmodule Genetic do
  @on_load :load_nif

  @moduledoc """
  Documentation for `Genetic`.
  """

  alias Types.Chromosome

  @default_pop_size 100

  def load_nif do
    :erlang.load_nif(~c"./genetic", 0)
  end

  def xor96, do: raise("NIF xor96/0 not implemented.")

  def initialize(genotype, opts \\ []) do
    pop_size = Keyword.get(opts, :population_size, @default_pop_size)

    # Stream.repeatedly(fn -> Chromosome.start_link(genes: genotype.()) end)
    population =
      Stream.repeatedly(fn -> genotype.() end)
      |> Enum.take(pop_size)

    Utilities.Genealogy.add_chromosomes(population)

    population
  end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      # Task.async(fn -> Chromosome.eval(chromosome, fitness_function) end)
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    # |> Enum.sort_by(fn c -> Chromosome.get_fitness(c) end, &>=/2)

    |> Enum.sort_by(fitness_function, &>=/2)
  end

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    selection_rate = Keyword.get(opts, :selection_rate, 0.8)

    n =
      case floor(length(population) * selection_rate) do
        x when rem(x, 2) == 0 -> x
        x -> x + 1
      end

    parents =
      select_fn
      |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2])
        Utilities.Genealogy.add_chromosome(p1, p2, c1)
        Utilities.Genealogy.add_chromosome(p1, p2, c2)
        [c1, c2 | acc]
      end
    )

    # |> Enum.map(&repair_chromosome(&1))
  end

  def repair_chromosome(chromosome) do
    genes = MapSet.new(chromosome.genes)
    new_genes = repair_helper(genes, 8)
    %Chromosome{chromosome | genes: new_genes}
  end

  defp repair_helper(genes, k) do
    if MapSet.size(genes) >= k do
      MapSet.to_list(genes)
    else
      num = :rand.uniform(8)
      repair_helper(MapSet.put(genes, num), k)
    end
  end

  def mutation(population, opts \\ []) do
    mut_rate = Keyword.get(opts, :mutation_rate, 0.05)

    mut_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.flip/1)

    n = floor(length(population) * mut_rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(fn c ->
      mutant = apply(mut_fn, [c])
      Utilities.Genealogy.add_chromosome(c, mutant)
      mutant
    end)
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    population
    |> evolve(problem, 0, 0, 0, opts)
  end

  def evolve(population, problem, generation, last_max_fitness, temp, opts \\ []) do
    population = evaluate(population, &problem.fitness_fun/1, opts)
    statistics(population, generation, opts)
    best = hd(population)
    best_fitness = best.fitness
    temp = 0.9 * (temp + (best_fitness - last_max_fitness))
    fit_str = (1.0 * best.fitness) |> :erlang.float_to_binary(decimals: 4)
    IO.write("\rCurrent Best:#{fit_str}\tGeneration: #{generation}")

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
        mutants = mutation(population, opts)
        offspring = children ++ mutants

        new_population =
          reinsertion(Enum.flat_map(parents, &Tuple.to_list(&1)), offspring, leftover, opts)

        evolve(new_population, problem, generation + 1, best_fitness, temp, opts)
    end
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end

  def statistics(population, generation, opts \\ []) do
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &Enum.sum(Enum.map(&1, fn c -> c.fitness end))
    ]

    stats = Keyword.get(opts, :statistics, default_stats)

    stats_map =
      stats
      |> Enum.reduce(%{}, fn {key, func}, acc -> Map.put(acc, key, func.(population)) end)

    Utilities.Statistics.insert(generation, stats_map)
  end

  def pmap(collection, module, function) do
    collection
    |> Enum.map(&Task.async(module, function, [&1]))
    |> Enum.map(&Task.await(&1))
  end
end
