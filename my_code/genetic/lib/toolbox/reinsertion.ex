defmodule Toolbox.Reinsertion do
  @moduledoc "Provide reinsertion strategies"

  @doc "Pure reinsertion is fast but can remove stronger characteristics of parents."
  @spec pure([any], [any], [any]) :: [any]
  def pure(_parents, offspring, _leftovers), do: offspring

  @doc "Elitist reinsertion keeps best of prior generation for the next generation."
  @spec elitist([any], [any], [any], number) :: [any]
  def elitist(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.sort_by(fn chromosome -> chromosome.fitness end, &>=/2)
      |> Enum.take(n)

    offspring ++ survivors
  end

  @doc "Uniform reinsertion randomly picks from prior generation to maintain diversity without regard to fitness."
  @spec uniform([any], [any], [any], number) :: [any]
  def uniform(parents, offspring, leftover, survival_rate) do
    old = parents ++ leftover
    n = floor(length(old) * survival_rate)
    survivors = old |> Enum.take_random(n)

    offspring ++ survivors
  end
end
