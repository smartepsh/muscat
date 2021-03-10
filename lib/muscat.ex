defmodule Muscat do
  alias Muscat.AugmentedMatrix

  @doc """
  Reduce a augmented matrix into `reduced row echelon form` and give the equation solution.

  The function name `rref` is taken from `Matlab`.

  ### Options

  - `:value_type` - The result value type, `:float`(default), `:fraction`.
  - `:precision` - If the `result_type` is `:float`, round the float.

  """
  @spec rref(augmented_matrix :: nonempty_list(nonempty_list(AugmentedMatrix.element()))) ::
          AugmentedMatrix.rref_result()
  def rref(augmented_matrix, opts \\ []) do
    augmented_matrix
    |> AugmentedMatrix.new()
    |> AugmentedMatrix.rref(opts)
  end
end
