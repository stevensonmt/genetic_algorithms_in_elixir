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


## Footnotes

[^1]: This is the point my background gets in the way of the metaphor.
    In biology, a population is a collection of organisms. Each organism can have one or many
    chromosomes. Each chromosome can have one or many genes. Each gene can have one or many
    values. Unclear if this is just the simplest implementation of a genetic algorithm and in
    future chapters or more advanced implementations the additional nested structure is utilized
    more consistent with the biology metaphor.
