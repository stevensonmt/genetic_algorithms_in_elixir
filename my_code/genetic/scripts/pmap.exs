defmodule DummyModule do
  def expensive(x) do
    x = x * x
    :timer.sleep(500)
    x
  end

  def inexpensive(x), do: x * x
end

data = for x <- 1..100, do: x

Benchee.run(
  %{
    "pmap, expensive" => fn -> Genetic.pmap(data, DummyModule, :expensive) end,
    "pmap, inexpensive" => fn -> Genetic.pmap(data, DummyModule, :inexpensive) end,
    "map, expensive" => fn -> Enum.map(data, &DummyModule.expensive(&1)) end,
    "map, inexpensive" => fn -> Enum.map(data, &DummyModule.inexpensive(&1)) end
  },
  memory_time: 7
)
