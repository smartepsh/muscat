defmodule Muscat.AugmentedMatrix do
  alias Muscat.Matrix
  alias Muscat.Fraction

  import Muscat.Fraction, only: [is_zero_fraction: 1]

  @type element :: Fraction.fraction_tuple() | integer()
  @type matrix :: nonempty_list(Matrix.Cell.t())

  @doc "Create augmented matrix by augmented matrix list"
  @spec new(augmented_matrix :: nonempty_list(nonempty_list(element()))) :: matrix()
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
        ) :: matrix()
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

  ### Options

  - `:value_type` - The result value type, `:float`(default), `:fraction`.
  - `:precision` - If the `result_type` is `:float`, round the float.

  """
  @type solution :: list(Fraction.t() | float())
  @type rref_result ::
          {:ok, solution()}
          | {:error, :no_solution}
          | {:error, :infinite_solutions}
          | {:error, :approximate_solution}
  @spec rref(augmented_matrix :: matrix()) :: rref_result()
  @spec rref(augmented_matrix :: matrix(), opts :: keyword()) :: rref_result()
  def rref(matrix, opts \\ []) do
    with upper_triangular_matrix <- upper_triangular_matrix(matrix),
         {:ok, solution_type} <- valid_solution_exists(upper_triangular_matrix) do
      solution =
        upper_triangular_matrix
        |> fit_single_solution_matrix(solution_type, opts)
        |> diagonal_matrix()
        |> identity_matrix()
        |> take_solution(opts)

      {:ok, solution}
    end
  end

  defp fit_single_solution_matrix(matrix, solution_type, opts) do
    matrix
    |> remove_zero_rows()
    |> set_default_rows_if_needed(solution_type, opts)
    |> sort_rows()
  end

  defp remove_zero_rows(matrix) do
    matrix
    |> Enum.group_by(& &1.row)
    |> Enum.reject(fn {_row, cells} ->
      Enum.all?(cells, &Fraction.is_zero_fraction(&1.value))
    end)
    |> Enum.map(fn {_row, cells} -> cells end)
    |> List.flatten()
  end

  defp set_default_rows_if_needed(matrix, :single_solution, _), do: matrix

  defp set_default_rows_if_needed(matrix, :infinite_solutions, opts) do
    default_value = Keyword.get(opts, :default_value, 1) |> Fraction.new()
    coefficient_cols = Matrix.col_count(matrix) - 1
    total_rows = Range.new(1, coefficient_cols) |> Enum.to_list()
    {new_matrix, exist_rows} = missing_main_diagonal_cell_idxs(matrix)

    new_cells =
      Enum.reduce(total_rows -- exist_rows, [], fn row_idx, acc ->
        coefficients =
          Range.new(1, coefficient_cols)
          |> Enum.map(fn
            ^row_idx -> %Matrix.Cell{row: row_idx, col: row_idx, value: Fraction.new(1)}
            col -> %Matrix.Cell{row: row_idx, col: col, value: Fraction.new(0)}
          end)

        constant = %Matrix.Cell{row: row_idx, col: coefficient_cols + 1, value: default_value}

        [constant | coefficients] ++ acc
      end)

    new_cells ++ new_matrix
  end

  defp sort_rows(matrix) do
    grouped_rows = Enum.group_by(matrix, & &1.row)
    rows = Enum.map(grouped_rows, fn {_row, cells} -> first_non_zero_cell(cells) end)

    Enum.zip(grouped_rows, rows)
    |> Enum.map(fn {{_row, cells}, row} ->
      Enum.map(cells, &Map.put(&1, :row, row))
    end)
    |> List.flatten()
    |> Enum.sort_by(&{&1.row, &1.col})
  end

  defp missing_main_diagonal_cell_idxs(matrix) do
    matrix
    |> Enum.group_by(& &1.row)
    |> Enum.reduce({matrix, []}, fn {row, cells}, {new_matrix, missing_rows} ->
      case first_non_zero_cell(cells) do
        ^row ->
          {new_matrix, [row | missing_rows]}

        col ->
          new = Enum.map(cells, &Map.put(&1, :row, col))

          new_matrix = new_matrix |> Matrix.remove_row(cells) |> Matrix.add_row(new)
          {new_matrix, [col | missing_rows]}
      end
    end)
  end

  defp first_non_zero_cell(row_cells) do
    row_cells
    |> Enum.sort_by(& &1.col)
    |> Enum.reduce_while(0, fn %{col: col, value: value}, _ ->
      if is_zero_fraction(value) do
        {:cont, nil}
      else
        {:halt, col}
      end
    end)
  end

  # defp replace_zero_rows_by_default_if_needed(matrix, :single_solution, _), do: matrix

  # defp replace_zero_rows_by_default_if_needed(matrix, :infinite_solutions, opts) do
  #   default_value = Keyword.get(opts, :default_value, Fraction.new(1))
  #   row_count = Matrix.row_count(matrix)

  #   matrix
  #   |> Enum.group_by(& &1.row)
  #   |> Enum.filter(fn {_row, cells} ->
  #     Enum.all?(cells, &Fraction.is_zero_fraction(&1.value))
  #   end)
  #   |> Enum.reduce(matrix, fn {row, cells}, acc ->
  #     constant_cell = Enum.at(cells, -1) |> Map.put(:value, default_value)
  #     main_cell = Enum.at(cells, row - 1) |> Map.put(:value, Fraction.new(1))  defp replace_zero_rows_by_default_if_needed(matrix, :single_solution, _), do: matrix

  # defp replace_zero_rows_by_default_if_needed(matrix, :infinite_solutions, opts) do
  #   default_value = Keyword.get(opts, :default_value, Fraction.new(1))
  #   row_count = Matrix.row_count(matrix)

  #   matrix
  #   |> Enum.group_by(& &1.row)
  #   |> Enum.filter(fn {_row, cells} ->
  #     Enum.all?(cells, &Fraction.is_zero_fraction(&1.value))
  #   end)
  #   |> Enum.reduce(matrix, fn {row, cells}, acc ->
  #     constant_cell = Enum.at(cells, -1) |> Map.put(:value, default_value)
  #     main_cell = Enum.at(cells, row - 1) |> Map.put(:value, Fraction.new(1))

  #     cells =
  #       cells
  #       |> Enum.sort_by(& &1.col)
  #       |> List.replace_at(-1, constant_cell)
  #       |> List.replace_at(row - 1, main_cell)

  #     Matrix.update_row(acc, cells)
  #   end)
  # end

  #     cells =
  #       cells
  #       |> Enum.sort_by(& &1.col)
  #       |> List.replace_at(-1, constant_cell)
  #       |> List.replace_at(row - 1, main_cell)

  #     Matrix.update_row(acc, cells)
  #   end)
  # end

  defp take_solution(identity_matrix, opts) do
    default_value = Keyword.get(opts, :default_value, :any)
    value_type = Keyword.get(opts, :value_type, :float)

    identity_matrix
    |> get_constant_column()
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
        |> replace_duplicated_by_zero()
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

  defp replace_duplicated_by_zero(matrix) do
    matrix
    |> filter_duplicated_rows()
    |> Enum.reduce(matrix, fn row_cells, acc ->
      Matrix.update_row(acc, Enum.map(row_cells, &Map.put(&1, :value, Fraction.new(0))))
    end)
  end

  defp filter_duplicated_rows(matrix) do
    matrix
    |> Enum.group_by(& &1.row)
    |> Enum.sort_by(fn {row, _cells} -> row end)
    |> Enum.map(fn {_row, cells} -> Enum.sort_by(cells, & &1.col) end)
    |> do_filter_duplicated()
  end

  defp do_filter_duplicated(rows, acc \\ [])
  defp do_filter_duplicated([], acc), do: acc

  defp do_filter_duplicated([cells | others], acc) do
    {zero_cells, valid_cells} =
      Enum.split_with(others, fn other_cells ->
        cells
        |> Enum.zip(other_cells)
        |> Enum.all?(fn {%{value: a}, %{value: b}} -> Fraction.equal?(a, b) end)
      end)

    do_filter_duplicated(valid_cells, zero_cells ++ acc)
  end

  defp do_elementary_transform(coefficient, base_row, row_cells) do
    row_cells
    |> Enum.sort_by(& &1.col)
    |> Enum.zip(base_row)
    |> Enum.map(fn {row_cell, base_cell} ->
      Matrix.update_cell(
        row_cell,
        &(&1 |> Fraction.minus(Fraction.multi(coefficient, base_cell.value)) |> Fraction.reduce())
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
        {:ok, :infinite_solutions}

      augmented_rank > element_count ->
        {:error, :approximate_solutions}

      true ->
        {:error, :no_solution}
    end
  end

  def rank(matrix) do
    matrix
    |> remove_zero_rows()
    |> Enum.map(& &1.row)
    |> Enum.uniq()
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
      &(&1 |> Fraction.minus(Fraction.multi(coefficient, target_cell.value)) |> Fraction.reduce())
    )
  end

  defp identity_matrix(diagonal_matrix) do
    diagonal_matrix
    |> Enum.group_by(& &1.row)
    |> Enum.reduce(diagonal_matrix, fn {row, row_cells}, matrix ->
      %{value: base_value} = Matrix.get_cell(row_cells, row, row)
      coefficient = Fraction.inverse(base_value)

      row_cells =
        Enum.map(row_cells, fn
          %{value: value} = cell when is_zero_fraction(value) ->
            cell

          cell ->
            Matrix.update_cell(cell, &(&1 |> Fraction.multi(coefficient) |> Fraction.reduce()))
        end)

      Matrix.update_row(matrix, row_cells)
    end)
  end

  defp get_constant_column(matrix) do
    col =
      matrix
      |> Enum.map(& &1.col)
      |> Enum.max()

    Matrix.get_col(matrix, col)
  end
end
