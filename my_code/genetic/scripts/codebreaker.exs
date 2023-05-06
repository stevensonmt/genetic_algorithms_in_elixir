defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome
  import Bitwise

  def genotype do
    genes = Stream.repeatedly(fn -> Enum.random(0..1) end) |> Enum.take(64)

    %Chromosome{genes: genes, size: 64}
  end

  def fitness_fun(chromosome) do
    IO.inspect(chromosome.genes, label: :GENES)
    target = "ILoveGeneticAlgorithsm"
    encrypted = 'LIjs`B`kqlfDibjwlqmhv'
    cipher = fn word, key -> Enum.map(word, &rem(Bitwise.bxor(&1, key), 32_768)) end
    # key = Integer.undigits(chromosome.genes, 2) |> IO.inspect(label: :here)

    key =
      chromosome.genes
      |> Enum.map_join(&Integer.to_string(&1))
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
  end

  def terminate?(population, _generation, _temperature),
    do: Enum.max_by(population, &Codebreaker.fitness_fun/1).fitness == 1
end

soln = Genetic.run(Codebreaker, crossover_type: &Toolbox.Crossover.single_point/2)

key = Integer.undigits(soln.genes, 2)

IO.write("\nThe key is #{key}\n")
