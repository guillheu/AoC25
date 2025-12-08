# aoc25

takaways:
- `%` and `int.modulo` don't actually do the same thing. `int.modulo` will always return a positive value (which is what you'd expect), but `%` will actually allow negative values for which the absolute value is smaller than the threshold.
- `set.is_disjoint` is great