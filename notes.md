*Ch 1*
Basic concept/flow of genetic algorithm:
* Initialize population
* Evaluate population (apply fitness function)
* Select parents
* Create children (crossover)
* Mutate children (introduce randomness)
* Loop back to evaluate

Population size (i.e., number of chormosomes)
- larger population -> longer transformation step
- smaller population -> more generations needed to produce soln and more likely to have premature convergence

Premature convergence - focusing on solution that appears "good enough" when more optimal solutions exist

Mutation helps fight premature convergence

?? Initial example shows how to get to a solution when you know what the answer is, but how
will genetic algorithms work when you don't know the solution ahead of time? ??

Fitness functions should be sorting/ordering (?)

Single point crossover I assume is faster per gen but may lead to more generations needed if
initial population small.
