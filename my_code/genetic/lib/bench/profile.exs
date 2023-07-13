defmodule DummyProblem do
  @moduledoc false
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Stream.repeatedly(fn -> Enum.random(0..1) end) |> Enum.take(100)

    %Chromosome{genes: genes, size: 100}
  end

  @impl true
  def fitness_fun(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?(_population, generation, _temp), do: generation == 1
end

defmodule Profiler do
  import ExProf.Macro

  def do_analyze do
    profile do
      Genetic.run(DummyProblem)
    end
  end

  def run do
    {records, _block_result} = __MODULE__.do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect("total = #{total_percent}")
  end
end

Profiler.run()
