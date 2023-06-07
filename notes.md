# Ch 1

## Basic concept/flow of genetic algorithm:

- Initialize population
- Evaluate population (apply fitness function)
- Select parents
- Create children (crossover)
- Mutate children (introduce randomness)
- Loop back to evaluate

### Population size (i.e., number of chormosomes)

- larger population -> longer transformation step
- smaller population -> more generations needed to produce soln and more
likely to have premature convergence

### Premature convergence

- focusing on solution that appears "good enough" when more optimal solutions exist
- Mutation helps fight premature convergence

> Initial example shows how to get to a solution when you know what the answer is, but how
will genetic algorithms work when you don't know the solution ahead of time? ??

- Fitness functions should be sorting/ordering (?)

> Single point crossover I assume is faster per gen but may lead to more generations needed if
> initial population is small.

### Mutation

Mutation probability in example is 5%.

- Impact of higher/lower probability of mutation?
    - I assume higher probability leads to slower optimization as higher chance of undoing
progress, however it might serve to counterbalance low initial population size/diversity
- The example mutation shuffles entire chromosome. How does single gene mutation or transposition mutation impact performance?
    - Again, I assume that broader mutations lead to more diversity and can offset small initial
population size at expense of potentially requiring more generations to acheive optimal solution

# Ch 2

Populations should use data structures that implement `Enumerable` protocol.
Using `List` as default will be simplest form of population.

- Initialize population
    - Random list of `chromosomes` (i.e., possible solutions)
    - Initialization function should be generic (i.e., not care structure used by chromosome)

- Evaluate population
    - Apply the fitness function (i.e., sort population according to fitness criteria)
    - Fitness will be defined unique to each problem
    - `population -> fitness.() -> sorted_population`

- Select parents
    - Elitism selection pairs strongest chromosomes as parents[^1]
    - `population -> transform_into_parent_pairs.() -> population_ready_for_crossover`

- Creating children
    - Apply the crossover function to parents
    - `parents -> crossover.() -> children` where size(children) == size(initial_pop)

- Mutation
    - Prevents premature convergence
    - `population -> mutate.() -> x_men` where `mutate` only affects a small % of population

- Termination criteria
    - criteria are problem-specific
    - simplest case is reaching desired value known ahead of time (max value in one-max e.g.)

- Hyperparameters
    - set prior to training algorithm
    - includes pop size, mutation rate, etc
    - use optional list of parameters in keyword list to allow rapidly adjusting these params
      (I would have instinctively used module attributes, but this is more opaque and less
       generic for a framework)

Using `mix run <project_root>/scripts/<script>.exs` is a pretty cool structure.

# Ch 3

What sort of problem would the age of chromosome determine fitness?
Is this simply another method of preventing premature convergence?

> Genes are typically represented using list types or other enumberable data types, like trees,
sets, and arrays.

Not sure about trees, but arrays, at least the `:array` implementation from Erlang, do
not implement `Enumerable`.

- Structs for chromosomes
    - needs fields for fitness, size, age, genes as basic foundation
    - why is size a basic need?
    - using `@enforce_keys` for fields that don't have a default defined but that shouldn't be
      nil is an obvious technique that I had not even realized was happening in other code

I have no formal comp sci education, but I've been reading about programming and practicing
writing programs for about 6 years off and on. This is probably the first time I've seen anyone
actually define the term **abstraction** in the context of programming and explicitly state the
purpose an abstraction should serve.

> The purpose of abstraction is sto force you to think of things at different levels
of specificity.

## Behaviours are a contract

- Behaviours enforce specifications by requiring certain functions be implemented

- Callbacks are function signatures with return types

- Since genetic algos require genotypes, fitness functions, and termination criteria, we need
  callbacks for all 3
    - all examples in book will use numbers for fitness but not necessary, only need to be
      sortable in some way

## Encoding

- Encoding = choice of data type to represent solutions
    - should not have extraneous information

- Importance of choosing correct and sparse encoding does not seem unique to genetic algos but
  I appreciate the point being emphasized here as it's something I continually struggle with

- Reducing solutions to collections of binary representations is simplest and allows bitstring
  as genotype
    - People are always doing clever things with bitwise that I don't grok, so I'm curious how
      much that sort of thing is going to come up in future chapters

- Permutation also common and probably more intuitive to me

- Real Value genotype feels inappropriately named so I must be missing something. The examples
  show a collection of genes with real-value alleles. Whereas permutation the entire collection
  of genes, i.e., the genotype, is what's assessed.

- Just going to ignore tree/graph genotypes but sounds very interesting from academic perspective

## OneMax

- OneMax run w/target 42 and size 42 reached in 51 generations, but with target and size 1000 took 5217 generations. Increasing population size to 300 with target 1000 took 2179 generations.

## Speller

- `Stream.repeatedly` + `Enum.random` is another little nugget with obvious utility that I see all the time and immediately forget whenever I could actually use it
- Increasing population size and mutation rate did not help convergence


Generic note: using module name as parameter and then dot notation to call functions from that
module -- another light bulb moment for me.

# Ch 4

Defining objective is critical step. Search objective is path, optimization max or min value

Constraint problems -- TIL the term for that type of problem on leetcode, really the entire
motivation for buying this book was solving the Einstein's house problem on Exercism

Thought creating a module attribute with a map or ETS table for looking up profits and weights
would be the obvious solution, but I like the use of `zip` in the fitness function.

> `zip -> map -> sum` can be rewritten as `zip_reduce`

If all cargo can fit the problem is trivial, so using the total available profit for ALL cargo
as a termination criteria seems odd ... which was apparently the author's point LOL.

## Penalty Functions

I'd like to see the penalty function defined as a private function independent of the fitness
function, even if it's only ever called by the fitness function.

## Termination Criteria

> The goal is to produce the best solution possible, even when you don't know that it's the absolute best.

This concept throws me off. I'm used to this concept of FP that states any function passed a
given input always returns the same output. It seems that you could give a genetic algo some
input and end up with slightly different output.

Possible errors in OneMax example for average fitness threshold. Since population is a list of
Chromosome structs, you need to first map the population to an enumerable of just genes before
calculating average fitness.

```
avg = population |> Enum.map(&Map.get(&1, :genes)) |> Enum.map(&(Enum.sum(&1) / length(&1)))
```

Also all three termination criteria converge on 42 and never terminate b/c the fitness function
is just the sum and the Genetic module sorts by `>=` after applying the fitness function. To
achieve convergence to minimum the fitness function needs to be changed to
`Enum.sum(choromosome.genes) * -1`. The average is trickier. Perhaps `Genetic.evaluate/3` should
be passed a sorter function in addition to the fitness function. This could be included in `opts`
keyword list.

Stopping after `n` generations is also more **fuzzy** than I typically think about finding
solutions.

Tracking time since last improvement -- light bulb moment

Temperature -> rate of improvement toward optimal solution

The new `Genetic.evolve/6` function header omits the `population` paramter. Also, the line
`best = Enum.max_by(population, &problem.fitness_function/1)` seemingly eliminates the need for
the `Genetic.evaluate/3` function. Previously the population was evaluated (i.e., sorted) with
`evaluate` and then `best = hd(population)` which should be the same output as the `max_by`.

Schema and theorems and heuristics, oh my! Getting into the fancy words now. :)

Heuristic -- estimate based on limited information, does not need to be (and cannot be) perfectly accurate for all situations (input?) but needs to capture essential characteristics of the problemto be solved.

Multiple factor optimization -- attempt to simplify to single objective
* weighted sum of multiple factors is one such method
    * should weights be in `opts` to generalize lib? maybe require something like `fitness_factors` as well with guards to catch that all values in `opts.fitness_factors` are available in `chromosome`

Perceptual data -- ranking cannot be calculated mathematically but ranking by user can transform into mathematical fitness via interactive fitness functions that require user input

### Errata:
> fit = IO.get("Rate from 1 to 10 ")

needs to be

> fit = IO.gets("Rate from 1 to 10 ") |> String.trim()

# Ch 5

Introductory discussion of selection, diversity, etc fairly intuitive for anyone with a biology background.

## Selection is biased sampling (is it?)

* Selection rate might be an important factor for the Sudoku problem ...

> Not sure I agree that selection and statistical sampling are variations on the same theme.
Statistical sampling is an attempt to define or describe a population based on a limited number
of individuals. Selection is about applying a definition or description to individuals to create
the population you want.

* High selection rates should slow convergence but improve diversity (I think)

## Importance of Selection Pressure

* Selection pressure of 1 is fully random? I would have thought selection pressure of 1 was fully elite while a pressure of 0 was fully randm.

> One extreme, when there is no selection pressure, is completely stochastic so that the search acts just like the Monte Carlo method [8], randomly sampling the space of feasible solutions.
- https://ecs.wgtn.ac.nz/foswiki/pub/Main/TechnicalReportSeries/ECSTR09-10.pdf

* Higher selection pressure leads to faster convergence

## Types of Selection

I don't understand how rewards based selection differs from fitness based selection. Feels like you're just shifting the fitness function to some mapping or reducing function that accumulates rewards and then determining fitness based on those rewards. I guess it doesn't matter that I don't understand the difference since the author says the book will only use fitness based selection strategies.

## Creating a Selection Toolbox

CODE!
Nice way to implement multiple strategies for the library. I think I still struggle with when to implement behaviours versus hard coding for things like this. Ideally I think `Toolbox` module would define some sort of behaviour for implementing strategies. So maybe there's a `selection` callback but also a `mutation` and `crossover` callback. Then you implement some defaults with like `Toolbox.Selection` module but users of the lib can extend with their own versions without having to touch the lib code. Thoughts?

## Adjusting the Selection Rate

```
n = round(length(population) * select_rate)
n = if rem(n, 2) == 0, do: n, else: n + 1
```
looks weird to me. I don't like the immediate rebinding. I'd rewrite as something like:
```
n =
  case round(length(population) * select_rate) do
    x when rem(x, 2) == 0 -> x
    x -> x + 1
  end
```

In getting the diff between population and parents, is using `MapSet` intermediate structure more efficient than just `Enum.filter`? I would guess only noticeably so for very large population/parent sizes.

## Implementing Common Selection Strategies

### Elitism

* Simplest, most common strategy
* Ignores diversity so tends to converge quickly

The implementation here assumes the input was sorted. Because this is not a private function, I don't think there's any guarantee that the input would be sorted and therefore no guarantee that the output is actually elite. Is there any way to enforce that the population would be sorted before calling `elite/2`?

### Random

* Maximizes diversity but ignores fitness
* Rarely useful except when **novelty** is a valuable quality in a solution
    * generating Sudoku or other puzzle starting scenarios
    * Even in this scenario, one could track 'seen' solutions and use this in elite selection as fitness criteria
    * If not tracking previously seen solutions, how does one determine novelty across generations?

### Tournament

1. Choose random `k` chromosomes to compete
2. Apply fitness evaluation to pool
3. Repeat `n` times to get `n` parents for next gen

* For `k = 1` equal to random selection
* For `k = length(population)` equal to elitism selection
* I'm not sure the above is entirely true b/c with random and elite you don't have the potential for selecting duplicates. Even with `k = length(population)` you can end up with multiple instances of a single chromosome in the parent pool, leading to less diversity than with straight `elite/2` strategy. Same issue with `k = 1` vs straight `random/2` strategy.
* The more complicated implementation to avoid duplicates resolves the above.

More stylistic bike-shedding. Rather than
```
0..(n-1)
|> Enum.map(
    fn _ ->
      population
      |> Enum.take_random(tournsize)
      |> Enum.max_by(&(&1.fitness))
   end
  )
```
I prefer
```
Stream.repeatedly(
    fn ->
      population
      |> Enum.take_random(tournsize)
      |> Enum.max_by(&(&1.fitness))
    end
  )
|> Enum.take(n)
```

### Roulette

Fitness-proportionate selection == weighted random?
Similar to tournament it balances fitness and diversity
* Feels like both would make it easy to have multiple selection pressures simulataneously with different degrees of influence. Any fitness function could do this, I suppose, but I could see one element used for increasing odds of selection for tournament and another element used for determining fitness overall. Not sure that makes sense.

> Roulette selection is by far the slowest and most difficult algorithm to implement

Why would that be the case? Seems like it would have been a way to speed up convergence in tournament by weighting competitors towards more fit individuals.

Regarding implementation I again prefer the `Stream.repeatedly(...) |> Enum.take(n)` pattern.
I also don't like the implementation for the "roulette wheel spin" because I believe it will be influenced by the order in which chromosomes are placed in the list. I think a more precise way of doing "weighted random" selection would be something like
```
population
|> Enum.reduce([], fn chromosome, weighted_population -> Enum.reduce(1..chromosome.fitness, weighted_population, fn _ -> [chromosome | weighted_population] end) end)
|> Enum.random()
```
I do recognize this is not an efficient implementation but it avoids unintentionally favoring items at the beginning of the list. If your population is an indexed store (:array, or %{ ndx => chromosome}) you could do the same but just with indexes represented in the accumulator, select the random index, and then take that chromosome from the population. This could save some space but is still not time-efficient.


# Ch 6

* Exploitation - using currently available information
    * Crossover is mechanism of exploitation in genetic algos
    * combining schemas to find better solutions

* Exploration - finding new information

Errata:
`defmodule NQueens` missing `do`

In the fitness function, is `Enum.uniq` necessary since no duplicates are possible when the chromosome is defined by shuffling `0..7`?
I don't get any stagnation with the example.
Author states that order one crossover is slow by virtue of what it does. The given implementation seems particularly inefficient though.

Don't use uniform crossover when chromosome represents a permutation -- it will generate invalid combinations?

Whole arithmetic crossover won't work for binary representations, only for real world values. Produces a weighted average at each gene with children being complementary. Can easily converge on poor solution. Iterates over whole chromosomes, so may be slower on larger solutions.

> Any reason we can't consider multiple parents to prevent convergence? Three contributors instead of two?

TODO: Messy single-point, Cycle, Multipoint crossover

Multiparent crossover implementation seems to only generate one child per parent pair, but why not two chidren as with simple two-parent single point crossover?

Mutiplarent crossover not recommended due to complexity it introduces, but why is this more complex than other methods for preventing premature convergence?

## Errata
`repair_chromosome/1` should be
```elixir
def repair_chromosome(chromosome) do
  genes = MapSet.new(chromosome.genes)
  new_genes = repair_helper(genes, 8) # book has chromosome instead of genes here
  %Chromosome{chromosome | genes: new_genes}
end
```

Why is `k` hard coded as 8?

In implementing cycle crossover it does not seem that gene data structure needs to be an ordered list in the sense of "sorted list" but rather a list in which order of elements is relevant. Indexable structures like arrays or maps of %{index => value} could be used as well.


# Chapter 7 Preventing Premature Convergence

First, let me say I am too immature for this thread title.

* `Integer.undigits/2` is much nicer than the provided key generation implementation
* Errata: fitness fun target is a charlist but passed to String.jaro_distance, therefore needs to be a string.
* Errata: scramble/2 implementation seems to treat `Enum.slice/3` as `Enum.slice(enum, start, stop)` when it is actually `Enum.slice(enum, start, size)`

The provided scramble/2 seems inefficient due to the use of Enum.slice in 3 areas and concatenating 3 lists together which requires iterating over the genes multiple times. I came up with a way to circumvent that approach, which I think is more efficient:
```elixir
def scramble(chromosome, n) do
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
            i < lo -> gs
            i > hi -> gs
            true ->
              new_val = :array.get(swaps[i], arr)
              :array.set(i, new_val, gs)
          end
        end)
    |> :array.to_list()

  %Chromosome{genes: genes, size: chromosome.size}
end
```

# Chapter 8 Replacing and Transitioning

* Why the "penalty" for schedules exceeding credit hours rather than strictly excluding them?

Mu plus Lambda = child competes with parents for survival
Mu comma Lambda = children compete with each, more children than needed are spawned

Elitist reinsertion is most common b/c reasonably fast and preserves strengths of prior generation for next generation.
Uniform reinsertion probably only useful in cases where low initial diversity leads to premature convergence or problem spaces in which diversity is more important than fitness.

`selection_rate`, `mutation_rate`, and `survival_rate` need to add up to 1.0 if population size needs to stay constant
if population allowed to grow or shrink by % of population each generation there will be exponential growth or decay unless mitigating solutions implemented.

while not addressed in detail, the idea that multi-population genetic algorithms can be parallelized suggests that those algorithms fit Elixir better than single population algorithms

# Chapter 9 Tracking Genetic Algorithms

Fitness function should probably take `opts` keyword list so that environments or specific weights can be passed. Alternatively if population is held in genserver then implementation is a callback where a fitness/2 function calls back to the population server to set the environment and then calls the fitness/1 function and lets the population server handle the implementation per environment. I prefer the former.

Why wrap ETS in GenServer?
Default stats definition of mean fitness seems wrong

Errata: opts should not have underscore in start_link def
missing comma after Utilities.Statistics entry in children list of application file

## Footnotes

[^1]: This is the point my background gets in the way of the metaphor.
    In biology, a population is a collection of organisms. Each organism can have one or many
    chromosomes. Each chromosome can have one or many genes. Each gene can have one or many
    values. Unclear if this is just the simplest implementation of a genetic algorithm and in
    future chapters or more advanced implementations the additional nested structure is utilized
    more consistent with the biology metaphor.
