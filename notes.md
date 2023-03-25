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
