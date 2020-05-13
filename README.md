# Regular

A Swift [regular expression](https://en.wikipedia.org/wiki/Regular_language) library supporting: 

* **Generically typed symbols** – Not only `String`s of `Character`, but _all_ Swift types in any `Sequence`.
* **Predicate based symbol matching** – Define match conditions on symbols such as `.require { $0.speed < 30 }`,
`.require { $0.color.isFairlyRed }`, or `require { $0.networkEvent.completedWithoutError }`.
* **Expression negation** – Regular provides `&` in expressions and supports _all_ boolean functions of subexpressions, not only `|`.
* **Linear run time** and constant memory use in the input sequence length.

# What is Regular for?

Regular is intended as a way to specify and validate event sequence expectations in tests, and to investigate whether this is a sensible 
thing to do in test specifications.

It might be useful for something else though.

# What isn't Regular for?

Regular is not a RegEx library for string based regular expressions. It does not attempt to support the syntax of RegEx.
Lots of libraries do this already and Swift already has support. Regular's intent is to let you use the same concepts to
process sequences of _anything_.

Regular is unlkely to be fast and I've not made any optimisation effort yet. However, the underlying algorithm is linear time time and
contant space, and various optimisations could be made without a change of API.

# TODO

Regular is currently work in progress. However, Regular has an NFA based matching implementation, and an API for creating expressions 
and building matchers from them.

- [ ] Expression Tests of composites and modifiers.
- [ ] Check it's actually useful for building expressions and matchers.
- [ ] Ensure naming in expression algebra isn't overly verbose.
