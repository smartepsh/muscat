# Muscat

![GitHub](https://img.shields.io/github/license/smartepsh/muscat?style=plastic)
![GitHub last commit](https://img.shields.io/github/last-commit/smartepsh/muscat?label=last%20update&style=plastic)
![Hex.pm](https://img.shields.io/hexpm/v/muscat?style=plastic)

**A simple pure elixir equation solver by [augmented matrix](https://en.wikipedia.org/wiki/Augmented_matrix).**

## Installation

```elixir
def deps do
  [
    {:muscat, "~> 0.3"}
  ]
end
```

## Usage

Very simple ! For example, To solve this equation:

![pic](https://user-images.githubusercontent.com/3273295/109914106-377c0c00-7cea-11eb-945d-48ad15e7fc3c.png)

Run `rref/1` or `rref/2` to solve the equation:

```elixir
augmented_matrix_parameter = [[1, 2, 3, 0], [3, 4, 7, 2], [6, 5, 9, 11]]

Muscat.rref(augmented_matrix_parameter)
#=> {:ok, [4, 1, -2]}
```

If the equation has infinite solutions, you could set the default value for base unknown number, and transform matrix to single solution.

### Fraction

`Muscat.rref/1` and `Muscat.rref/2` support fraction value in parameters:

```elixir
Muscat.rref([{1, 2}, 1])
```

`{1, 2}` means `1/2`, the first element in tuple is `numerator` and the second one is `denominator`.

> `Muscat.Fraction` also provides some simple fraction calculation rules. See more details in the module doc.

## Targets

- [x] a unique solution
- [x] infinite solutions
- [ ] approximate solutions
