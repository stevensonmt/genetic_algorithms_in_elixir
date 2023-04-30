defmodule Toolbox.Crossover do
  alias Types.Chromosome

  def single_point(p1, p2) do
    cx_point = :rand.uniform(p1.size)
    {p1_head, p1_tail} = Enum.split(p1.genes, cx_point)
    {p2_head, p2_tail} = Enum.split(p2.genes, cx_point)
    {c1, c2} = {p1_head ++ p2_tail, p2_head ++ p1_tail}
    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  def single_point([]), do: raise("You must have at least one parent!")
  def single_point([p1 | []]), do: p1

  def single_point(parents) do
    parents
    |> Enum.chunk_every(2, 1, [hd(parents)])
    |> Enum.map(&List.to_tuple(&1))
    |> Enum.reduce([], fn {p1, p2}, chd ->
      single_point(p1, p2)
      |> Tuple.to_list()
      |> Kernel.++(chd)
    end)
  end

  def uniform(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  def order_one_crossover(p1, p2) do
    lim = Enum.count(p1.genes) - 1

    # get random range 
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution 
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # Combine
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p2.size}}
  end

  def whole_arithmetic_crossover(p1, p2, alpha) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        {x * alpha + y * (1 - alpha), x * (1 - alpha) + y * alpha}
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  def messy_single_point(p1, p2) do
    cx1 = :rand.uniform(length(p1.genes) - 1)
    cx2 = :rand.uniform(length(p2.genes) - 1)
    {h1, t1} = Enum.split(p1.genes, cx1)
    {h2, t2} = Enum.split(p2.genes, cx2)
    c1 = h1 ++ t2
    c2 = h2 ++ t1
    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  def multipoint(p1, p2, k) do
    cxs =
      Stream.repeatedly(fn -> :rand.uniform(length(p1.genes) - 1) end)
      |> Enum.take(k)

    cxs
    |> Enum.reduce({p1.genes, p2.genes}, fn cx, {c1, c2} ->
      [{h1, t1}, {h2, t2}] = Enum.map([c1, c2], &Enum.split(&1, cx))
      {h1 ++ t2, h2 ++ t1}
    end)
    |> Tuple.to_list()
    |> Enum.map(fn genes -> %Chromosome{genes: genes, size: length(genes)} end)
    |> List.to_tuple()
  end

  def cycle(p1, p2) do
    [arr1, arr2] =
      [p1.genes, p2.genes]
      |> Enum.map(fn list ->
        list |> Enum.with_index() |> Map.new(fn {v, k} -> {k, v} end)
      end)

    cycle_helper(arr1, arr2, 0, %{}, %{})
  end

  defp cycle_helper(arr1, arr2, ndx, c1, c2) do
    if arr1[ndx] in Map.values(c1) do
      cycle_completed(arr1, arr2, c1, c2)
    else
      v1 = Map.get(arr1, ndx)
      v2 = Map.get(arr2, ndx)
      c1 = Map.put(c1, ndx, v1)
      c2 = Map.put(c2, ndx, v2)
      ndx = find_index(v1, arr2)
      cycle_helper(arr1, arr2, ndx, c1, c2)
    end
  end

  defp cycle_completed(arr1, arr2, c1, c2) do
    [{arr2, c1}, {arr1, c2}]
    |> Enum.map(fn {p, c} ->
      p
      |> Enum.reduce(c, fn {k, v}, acc ->
        Map.put_new(acc, k, v)
      end)
    end)
    |> Enum.map(fn map -> map |> Enum.sort_by(fn {k, _v} -> k end) |> Enum.map(&elem(&1, 1)) end)
    |> Enum.map(fn genes -> %Chromosome{genes: genes, size: length(genes)} end)
    |> List.to_tuple()
  end

  defp find_index(val, arr) do
    arr |> Enum.find(fn {_k, v} -> v == val end) |> elem(0)
  end
end
