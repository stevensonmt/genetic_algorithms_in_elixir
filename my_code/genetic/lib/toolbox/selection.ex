defmodule Toolbox.Selection do
  @moduledoc "A place to keep selection strategy implementations. This avoids having to reimplement the same strategies over and over."

  @doc "Assumes population is pre-sorted."
  @spec elite([any], integer) :: [any]
  def elite(population, n) do
    population
    |> Enum.take(n)
  end

  @doc "Since taking randomly, whether population is pre-sorted or not is irrelevant."
  @spec random([any], integer) :: [any]
  def random(population, n) do
    population
    |> Enum.take_random(n)
  end

  @doc "Tournament selection with tournament size `k` and selection size `n`. Pre-sorting population again seems irrelevant since tournament competitors are chosen randomly. Allows duplicates."
  @spec tournament([any], integer, integer) :: [any]
  def tournament(population, n, k) do
    Stream.repeatedly(fn ->
      population
      |> Enum.take_random(k)
      |> Enum.max_by(& &1.fitness)
    end)
    |> Enum.take(n)
  end

  @doc "Tournament selection with tournament size `k` and selection size `n` that does not allow duplicates. Again random selection of tournament competitors renders pre-sorting of population irrelevant."
  @spec tournament_no_duplicates([any], integer, integer) :: [any]
  def tournament_no_duplicates(population, n, k) do
    selected = MapSet.new()
    tournament_helper(population, n, k, selected)
  end

  defp tournament_helper(population, n, k, selected) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      chosen =
        population
        |> Enum.take_random(k)
        |> Enum.max_by(& &1.fitness)

      tournament_helper(population, n, k, MapSet.put(selected, chosen))
    end
  end

  @doc "Roulette selection weights odds of random selection. Pre-sorting population not necessary."
  @spec roulette([any], integer) :: [any]
  def roulette(population, n) do
    sum_fitness =
      population
      |> Enum.reduce(0, fn chromosome, acc -> acc + chromosome.fitness end)

    Stream.repeatedly(fn ->
      u = :rand.uniform() * sum_fitness

      population
      |> Enum.reduce_while(0, fn x, sum ->
        if x.fitness + sum > u do
          {:halt, x}
        else
          {:cont, x.fitness + sum}
        end
      end)
    end)
    |> Enum.take(n)
  end
end
