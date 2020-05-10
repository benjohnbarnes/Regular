# Regular

A Swift [regular expression](https://en.wikipedia.org/wiki/Regular_language) library supporting: 

* **Generically typed symbols** – not only characters, but _all_ Swift types.
* **Predicate based symbol matching** – check if a `Speed` is `fast` of `slow`. Check if a `Color` is `red` or `green`. Check if a 
`NetworkEvent` was `critical` or `benign`.
* **Expression negation** – Regular provides `&` in expressions and supports _all_ boolean functions of subexpressions, not only `|`.
* **Linear run time** and constant memory use in the input sequence length.

Regular is intended as a way to specify and validate event sequence expectations in tests, and to validate if this is actually a good way
to write tests. Maybe it is useful for something else too?

Regular is currently work in progress. However, Regular has an NFA based matching implementation, and an API for creating expressions 
and building matchers from them.

# What Regular isn't

Regular is not a string based regular expression library and does not attempt to support the syntax of string based regular expressions.
Lots of libraries do this already, and Swift has support in its standard library. 

Regular wants to let you use the same kinds of concept to process sequences of _anything_.

# TODO
- [ ] Expression Tests of composites and modifiers.
- [ ] Check it's actually useful for building expressions and matchers.
- [ ] Ensure naming in expression algebra isn't overly verbose.
