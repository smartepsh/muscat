defmodule Muscat do
  defdelegate rref(augmented_matrix, opts), to: Muscat.AugmentedMatrix
  defdelegate rref(augmented_matrix), to: Muscat.AugmentedMatrix
  defdelegate new(augmented_matrix), to: Muscat.AugmentedMatrix
  defdelegate new(coefficient_matrix, constant_column), to: Muscat.AugmentedMatrix
end
