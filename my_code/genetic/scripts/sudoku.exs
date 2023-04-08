defmodule Sudoku do
  @behaviour Problem

  alias Types.Chromosome

  @input File.read!("#{__DIR__}/sudoku.txt")

  @impl true
  def genotype do
    # Encode as bitstring of len 81 (since unable to pass args to 
    # genotype/0 as currently defined by behaviour have to limit
    # grid size to 9x9
    puzzle = @input |> encode()

    for c <- puzzle do
      if c == 0 do
        :rand.uniform(9)
      else
        c
      end
    end
    |> to_chromosome()
  end

  @impl true
  def fitness_fun(chromosome) do
    valid_rows = valid_rows(chromosome.genes)
    valid_cols = valid_cols(chromosome.genes)
    valid_grids = valid_grids(chromosome.genes)
    valid_rows + valid_cols + valid_grids
  end

  defp valid_rows(grid) do
    grid
    |> Enum.chunk_every(9)
    |> Enum.filter(fn row -> 1..9 |> Enum.all?(fn i -> i in row end) end)
    |> Enum.count()
  end

  defp valid_cols(grid) do
    grid
    |> Enum.chunk_every(9)
    |> Enum.zip()
    |> Enum.flat_map(&Tuple.to_list(&1))
    |> valid_rows()
  end

  defp valid_grids(grid) do
    grid
    |> Enum.chunk_every(9)
    |> Enum.map(&Enum.chunk_every(&1, 3))
    |> Enum.zip()
    |> Enum.flat_map(&Tuple.to_list/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.flatten/1)
    |> Enum.filter(fn subgrid -> 1..9 |> Enum.all?(fn i -> i in subgrid end) end)
    |> Enum.count()
  end

  @impl true
  def terminate?(_population, _generation, temperature) when temperature < 0.01, do: :no_but_reset
  def terminate?(_population, generation, _temperature) when generation > 50_000, do: true

  def terminate?(population, _generation, _temperature) do
    population
    |> Enum.any?(fn chromosome -> chromosome.fitness == 27 end)
  end

  def try_to_int(c) do
    try do
      String.to_integer(c)
    rescue
      _ -> 0
    end
  end

  def encode(input) when is_binary(input) do
    input |> process_input() |> encode()
  end

  def encode(input) do
    input
  end

  defp process_input(input) do
    input
    |> String.replace("\n", "")
    |> String.graphemes()
    |> Enum.map(&try_to_int(&1))
  end

  defp to_chromosome(encoded) do
    %Chromosome{genes: encoded, age: 0, size: 81}
  end
end

input = File.read!("#{__DIR__}/sudoku.txt")

soln =
  Genetic.run(Sudoku, population_size: 5_000, puzzle: input |> Sudoku.encode(), mutation_rate: 0)

IO.write("\n")
IO.inspect(soln)
