defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:genetic] ++ Mix.compilers()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Genetic.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libgraph, "~> 0.13"},
      {:gnuplot, "~> 1.19"},
      {:alex, "~> 0.3.2"},
      {:benchee, "~> 1.0.1"},
      {:exprof, "~> 0.2.0"},
      {:stream_data, "~> 0.5", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

defmodule Mix.Tasks.Compile.Genetic do
  use Mix.Task.Compiler

  def run(_args) do
    {result, _errcode} =
      System.cmd(
        "gcc",
        ["-fpic", "-shared", "-o", "genetic.so", "src/genetic.c"],
        stderr_to_stdout: true
      )

    IO.puts(result)
  end
end
