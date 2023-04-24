defmodule NQueens do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Enum.shuffle(0..7)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_fun(chromosome) do
    diag_clashes = diag_clashes(chromosome.genes)
    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  defp diag_clashes(genes) do
    for i <- 0..7, j <- 0..7, i != j do
      dx = abs(i - j)
      dy = (Enum.at(genes, i) - Enum.at(genes, j)) |> abs()

      if dx == dy do
        1
      else
        0
      end
    end
  end

  @impl true
  def terminate?(population, _generation, _temperature) do
    Enum.max_by(population, &NQueens.fitness_fun/1).fitness == 8
  end
end

soln = Genetic.run(NQueens, crossover_type: &Toolbox.Crossover.single_point/2)

IO.write("\n")
IO.inspect(soln)
