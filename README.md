# Muscat

![GitHub](https://img.shields.io/github/license/smartepsh/muscat?style=plastic)
![GitHub last commit](https://img.shields.io/github/last-commit/smartepsh/muscat?label=last%20update&style=plastic)
![Hex.pm](https://img.shields.io/hexpm/v/muscat?style=plastic)

**A simple pure elixir equation solver by [augmented matrix](https://en.wikipedia.org/wiki/Augmented_matrix).**

## Installation

```elixir
def deps do
  [
    {:muscat, "~> 0.1.0"}
  ]
end
```

## Usage

Very simple ! For example, To solve this equation:

![pic](https://user-images.githubusercontent.com/3273295/109914106-377c0c00-7cea-11eb-945d-48ad15e7fc3c.png)

1. Create a augmented matrix by:

```elixir
coefficient_matrix_parameter = [[1, 2, 3], [3, 4, 7], [6, 5, 9]]
constant_column = [0, 2, 11]

Muscat.new(coefficient_matrix_parameter, constant_column)
```

Or

```elixir
augmented_matrix_parameter = [[1, 2, 3, 0], [3, 4, 7, 2], [6, 5, 9, 11]]

Muscat.new(augmented_matrix_parameter)
```

2. Run `rref/1` or `rref/2` to solve the equation:

```elixir
Muscat.rref(augmented_matrix)
#=> {:ok, [4, 1, -2]}
```

### Fraction

`Muscat.new/1` and `Muscat.new/2` support fraction value in parameters:

```elixir
Muscat.new([{1, 2}, 1])
```

`{1, 2}` means `1/2`, the first element in tuple is `numerator` and the second one is `denominator`.

> `Muscat.Fraction` also provides some simple fraction calculation rules. See more details in the module doc.

## Targets

- [x] a unique solution
- [ ] infinite solutions
- [ ] approximate solutions
