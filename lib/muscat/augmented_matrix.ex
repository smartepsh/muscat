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

        %Matrix.Cell{x: row, y: col, value: value}
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
end
