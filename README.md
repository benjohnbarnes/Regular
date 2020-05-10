# Regular

A Swift regular expression library supporting: 

* Genericly typed symbols – not only characters, but _any_ Swift type.
* Predicate based symbol matching – check if a vector is short of long. Check if a colour is red or gressn. Check if an event was critical or
benign.
* Expression negation – this allows `!`, `&` and `^` in expressions, as well as the more usualy used `|`.
* Run time linear in the length of the input sequence (and linear in the size of the expression).

Regular is inteded as a way to specifcy and validate event sequence expectations in unit tests, with a hope it'll be useful in other ways too. 

Regular is currently work in progress. It does not yet have a designed public API. It does have an NFA implementation that proove the concept by implementing the objectives.
