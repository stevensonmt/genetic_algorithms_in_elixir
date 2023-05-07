defmodule Toolbox.Mutation do
  @moduledoc false
  alias Types.Chromosome

  import Bitwise

  @doc "Flip is only applicable to binary genotypes."
  def flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(&bxor(&1, 1))

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def flip(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn g ->
        if :rand.uniform() < p do
          bxor(g, 1)
        else
          g
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  @doc "Scramble is versatile and can apply to almost any genotype structure."
  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome, n) do
    start = :rand.uniform(n - 1)

    {lo, hi} =
      if start + n >= chromosome.size do
        {start - n, start}
      else
        {start, start + n}
      end

    head = Enum.slice(chromosome.genes, 0, lo)
    mid = Enum.slice(chromosome.genes, lo, n)
    tail = Enum.slice(chromosome.genes, hi, chromosome.size - hi)
    %Chromosome{genes: head ++ Enum.shuffle(mid) ++ tail, size: chromosome.size}
  end

  def scramble2alt(chromosome, n) do
    start = :rand.uniform(n - 1)

    {lo, hi} =
      if start + n >= chromosome.size do
        {start - n, start}
      else
        {start, start + n}
      end

    swaps =
      lo..hi
      |> Enum.zip(Enum.shuffle(lo..hi))
      |> Map.new()

    arr = :array.from_list(chromosome.genes)

    genes =
      0..:array.sparse_size(arr)
      |> Enum.reduce(arr, fn i, gs ->
        cond do
          i < lo ->
            gs

          i > hi ->
            gs

          true ->
            new_val = :array.get(swaps[i], arr)
            :array.set(i, new_val, gs)
        end
      end)
      |> :array.to_list()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  @doc "Gaussian applies to real-value genotypes"
  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)

    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))

    genes =
      chromosome.genes
      |> Enum.map(fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  @doc "Swap can be done for any genotype"
  def swap(chromosome, n \\ 1) do
    arr = chromosome.genes |> :array.from_list()

    genes =
      1..n
      |> Enum.reduce(arr, fn _i, gs ->
        [swap1, swap2] =
          Stream.repeatedly(fn -> :rand.uniform(:array.sparse_size(arr) - 1) end) |> Enum.take(2)

        v1 = :array.get(swap1, gs)
        v2 = :array.get(swap2, gs)
        gs = :array.set(swap1, v2, gs)
        :array.set(swap2, v1, gs)
      end)
      |> :array.to_list()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  @doc "Uniform applies to binary or real-value genotypes but not permutations. For binary genotypes, the genotype parameter needs to be true. No absolute maximum value is assumed, but the limit for each mutation is arbitrarily fixed at double the current maximal value. Implementation does not ensure unique values for each gene. If unique values are necessary, the genotype parameter must be :unique."
  def uniform(chromosome, true) do
    genes = Stream.repeatedly(fn -> :rand.uniform(2) - 1 end) |> Enum.take(chromosome.size)
    %Chromosome{genes: genes, size: chromosome.size}
  end

  def uniform(chromosome, false) do
    genes =
      Stream.repeatedly(fn -> :rand.uniform(Enum.max(chromosome.genes) * 2) end)
      |> Enum.take(chromosome.size)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def uniform(chromosome, :unique) do
    genes =
      Stream.repeatedly(fn -> :rand.uniform(Enum.max(chromosome.genes) * 2) end)
      |> Enum.reduce_while(MapSet.new(), fn n, acc ->
        if MapSet.size(acc) == chromosome.size do
          {:halt, acc}
        else
          {:cont, MapSet.put(acc, n)}
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def uniform(chromosome), do: uniform(chromosome, false)

  @doc "Invert just reverses the genes, I guess."
  def invert(chromosome),
    do: %Chromosome{genes: Enum.reverse(chromosome.genes), size: chromosome.size}
end
