defmodule Muscat.AugmentedMatrix do
  alias Muscat.Matrix
  alias Muscat.Fraction
  import Muscat.Fraction, only: [is_zero_fraction: 1]

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
         {:ok, :single_solution} <- valid_solution_exists(upper_triangular_matrix) do
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

    {_col, last_column} =
      identity_matrix
      |> Enum.group_by(& &1.col)
      |> Enum.max_by(fn {col, _} -> col end)

    last_column
    |> Enum.sort_by(& &1.row)
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
    case Matrix.row_count(matrix) do
      1 ->
        matrix

      row_count ->
        Range.new(1, row_count - 1)
        |> Enum.reduce(matrix, fn row, matrix ->
          elementary_row_transform(matrix, row)
        end)
    end
  end

  defp elementary_row_transform(matrix, row) do
    matrix = swap_rows_if_needed(matrix, row)

    case Matrix.get_cell(matrix, row, row) do
      %{value: value} when is_zero_fraction(value) ->
        matrix

      diagonal_cell ->
        base_row = Matrix.get_row(matrix, row)
        {other_cells, transform_cells} = Enum.split_with(matrix, &(&1.row <= row))

        cells =
          transform_cells
          |> Enum.group_by(& &1.row)
          |> Enum.map(fn {target_row, row_cells} ->
            case Matrix.get_cell(matrix, target_row, row) do
              %{value: value} when is_zero_fraction(value) ->
                row_cells

              %{value: target_value} ->
                coefficient = Fraction.divide(target_value, diagonal_cell.value)
                do_elementary_transform(coefficient, base_row, row_cells)
            end
          end)
          |> List.flatten()

        cells ++ other_cells
    end
  end

  defp do_elementary_transform(coefficient, base_row, row_cells) do
    row_cells
    |> Enum.sort_by(& &1.col)
    |> Enum.zip(base_row)
    |> Enum.map(fn {row_cell, base_cell} ->
      Matrix.update_cell(
        row_cell,
        &Fraction.minus(&1, Fraction.multi(coefficient, base_cell.value))
      )
    end)
  end

  defp swap_rows_if_needed(matrix, row) do
    case matrix |> Enum.reject(&(&1.row < row)) |> Matrix.max_abs_row_in_col(row) do
      ^row ->
        matrix

      :no_data ->
        matrix

      max_row ->
        Matrix.swap_row(matrix, row, max_row)
    end
  end

  defp valid_solution_exists(upper_triangular_matrix) do
    constant_column = get_constant_column(upper_triangular_matrix)
    coefficient_matrix = upper_triangular_matrix -- constant_column

    augmented_rank = rank(upper_triangular_matrix)
    coefficient_rank = rank(coefficient_matrix)
    element_count = element_number(coefficient_matrix)

    cond do
      augmented_rank == coefficient_rank and
          coefficient_rank == element_count ->
        {:ok, :single_solution}

      augmented_rank == coefficient_rank and
          coefficient_rank < element_count ->
        {:error, :infinite_solutions}

      augmented_rank > element_count ->
        {:error, :approximate_solutions}

      true ->
        {:error, :no_solution}
    end
  end

  def rank(matrix) do
    matrix
    |> Enum.group_by(& &1.row)
    |> Enum.reject(fn {_row, cells} ->
      Enum.all?(cells, &Fraction.is_zero_fraction(&1.value))
    end)
    |> length()
  end

  def element_number(coefficient_matrix) do
    coefficient_matrix
    |> Enum.group_by(& &1.col)
    |> Enum.to_list()
    |> length()
  end

  defp diagonal_matrix(upper_triangular_matrix) do
    row_count = Matrix.row_count(upper_triangular_matrix)

    Range.new(row_count, 1)
    |> Enum.reduce(upper_triangular_matrix, fn row, matrix ->
      eliminate_element(matrix, row)
    end)
  end

  defp eliminate_element(matrix, row) do
    base_cell = Matrix.get_cell(matrix, row, row)
    col_cells = Matrix.get_col(matrix, row)
    constant_column = get_constant_column(matrix)
    base_constant = Enum.find(constant_column, &(&1.row == row))

    {col_cells, constant_column} =
      col_cells
      |> Enum.zip(constant_column)
      |> Enum.reduce({[], []}, fn
        {^base_cell = col_cell, constant}, {col_cells, constant_column} ->
          {[col_cell | col_cells], [constant | constant_column]}

        {col_cell, constant}, {col_cells, constant_column}
        when is_zero_fraction(col_cell.value) ->
          {[col_cell | col_cells], [constant | constant_column]}

        {col_cell, constant}, {col_cells, constant_column} ->
          coefficient = Fraction.divide(col_cell.value, base_cell.value)
          col_cell = do_eliminate_element(col_cell, coefficient, base_cell)
          constant = do_eliminate_element(constant, coefficient, base_constant)
          {[col_cell | col_cells], [constant | constant_column]}
      end)

    matrix
    |> Matrix.update_col(col_cells)
    |> Matrix.update_col(constant_column)
  end

  defp do_eliminate_element(cell, coefficient, target_cell) do
    Matrix.update_cell(
      cell,
      &(&1 |> Fraction.minus(Fraction.multi(coefficient, target_cell.value)))
    )
  end

  defp identity_matrix(diagonal_matrix) do
    diagonal_matrix
  end

  defp get_constant_column(matrix) do
    col =
      matrix
      |> Enum.map(& &1.col)
      |> Enum.max()

    Matrix.get_col(matrix, col)
  end
end
