# Regular

A Swift regular expression library supporting: 

* **Generically typed symbols** – not only characters, but _all_ Swift types.
* **Predicate based symbol matching** – check if a `Speed` is `fast` of `slow`. Check if a `Color` is `red` or `green`. Check if a 
`NetworkEvent` was `critical` or `benign`.
* **Expression negation** – Regular provides `&` in expressions and supports _all_ boolean functions of subexpressions, not only `|`.
* **Linear run time** and constant memory use in the input sequence length.

Regular is intended as a way to specify and validate event sequence expectations in tests, and to validate if this is actually a good way
to write tests. Maybe it is useful for something else too?

Regular is currently work in progress. However, Regular has an NFA based matching implementation, and an API for creating expressions 
and building matchers from them.

# TODO
- [ ] Expression Tests of composites and modifiers.
- [ ] Check it's actually useful for building expressions and matchers.
- [ ] Ensure naming in expression algebra isn't overly verbose.
