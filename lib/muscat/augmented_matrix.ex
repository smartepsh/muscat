defmodule Muscat.AugmentedMatrix do
  alias Muscat.Matrix
  alias Muscat.Fraction

  @type element :: Fraction.fraction_tuple() | integer()
  @type matrix :: nonempty_list(Matrix.Cell.t())

  @doc "Create augmented matrix by augmented matrix list"
  @spec new(augmented_matrix :: nonempty_list(nonempty_list(element()))) ::
          nonempty_list(matrix())
  def new(augmented_matrix) do
    if all_list?(augmented_matrix) and valid_list?(augmented_matrix) do
      rows_count = length(augmented_matrix)
      cols_count = augmented_matrix |> List.first() |> length()

      for row <- Range.new(1, rows_count), col <- Range.new(1, cols_count) do
        value =
          augmented_matrix
          |> Enum.at(row - 1)
          |> Enum.at(col - 1)
          |> Fraction.new()

        %Matrix.Cell{row: row, col: col, value: value}
      end
    else
      raise ArgumentError, "The given parameter can not generate the augmented matrix."
    end
  end

  @doc "Create augmented matrix by coefficient matrix list and constant column list"
  @spec new(
          coefficient_matrix :: nonempty_list(nonempty_list(element())),
          constant_column :: nonempty_list(element())
        ) :: nonempty_list(matrix())
  def new(coefficient_matrix, constant_column) do
    if length(coefficient_matrix) == length(constant_column) do
      coefficient_matrix
      |> Enum.zip(constant_column)
      |> Enum.map(fn {coefficients, constant} ->
        coefficients ++ [constant]
      end)
      |> new()
    else
      raise ArgumentError, "The given parameter can not generate the augmented matrix."
    end
  end

  defp all_list?(lists) do
    lists |> Enum.map(&is_list/1) |> Enum.all?(& &1)
  end

  defp valid_list?(lists) do
    case lists |> Enum.map(&length/1) |> Enum.uniq() do
      [0] -> false
      [_length] -> true
      _ -> false
    end
  end

  @doc """
  Reduce a augmented matrix into `reduced row echelon form` and give the equation solution.

  The function name `rref` is taken from `Matlab`.

  ### Options

  - `:value_type` - The result value type, `:float`(default), `:fraction`.
  - `:precision` - If the `result_type` is `:float`, round the float.

  """
  @type solution :: list(Fraction.t() | float() | :any)
  @spec rref(augmented_matrix :: matrix()) ::
          {:ok, solution()}
          | {:error, :no_solution}
          | {:error, :infinite_solutions}
          | {:error, :approximate_solution}
  @spec rref(augmented_matrix :: matrix(), opts :: keyword()) ::
          {:ok, solution()}
          | {:error, :no_solution}
          | {:error, :infinite_solutions}
          | {:error, :approximate_solution}
  def rref(matrix, opts \\ []) do
    with upper_triangular_matrix <- upper_triangular_matrix(matrix),
         :ok <- valid_solution_exists(upper_triangular_matrix) do
      solution =
        upper_triangular_matrix
        |> diagonal_matrix()
        |> identity_matrix()
        |> take_solution(opts)

      {:ok, solution}
    end
  end

  defp take_solution(identity_matrix, opts) do
    default_value = Keyword.get(opts, :default_value, :any)
    value_type = Keyword.get(opts, :value_type, :float)

    [{_y, last_column}] =
      identity_matrix
      |> Enum.group_by(& &1.y)
      |> Enum.max_by(fn {y, _} -> y end)

    last_column
    |> Enum.sort_by(& &1.x)
    |> Enum.map(fn
      %{value: :any} ->
        default_value

      %{value: fraction} ->
        case value_type do
          :float -> Fraction.to_float(fraction, opts)
          fraction -> fraction
        end
    end)
  end

  defp upper_triangular_matrix(matrix) do
    matrix
  end

  defp valid_solution_exists(upper_triangular_matrix) do
    upper_triangular_matrix
  end

  defp diagonal_matrix(upper_triangular_matrix) do
    upper_triangular_matrix
  end

  defp identity_matrix(diagonal_matrix) do
    diagonal_matrix
  end
end
