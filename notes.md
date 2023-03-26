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

## Footnotes

[^1]: This is the point my background gets in the way of the metaphor.
    In biology, a population is a collection of organisms. Each organism can have one or many
    chromosomes. Each chromosome can have one or many genes. Each gene can have one or many
    values. Unclear if this is just the simplest implementation of a genetic algorithm and in
    future chapters or more advanced implementations the additional nested structure is utilized
    more consistent with the biology metaphor.
