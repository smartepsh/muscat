defmodule Muscat.MatrixTest do
  use ExUnit.Case

  alias Muscat.{Matrix, Fraction}

  setup do
    matrix =
      Muscat.AugmentedMatrix.new([
        [1, 2, 3, 4],
        [2, 2, 3, 4],
        [3, 2, 3, 4],
        [-1, -5, -6, 2],
        [4, 3, 2, 3]
      ])

    {:ok, matrix: matrix}
  end

  test "get_row/2", %{matrix: matrix} do
    assert [2.0, 2.0, 3.0, 4.0] = Matrix.get_row(matrix, 2) |> get_value()
  end

  test "get_col/2", %{matrix: matrix} do
    assert [2.0, 2.0, 2.0, -5.0, 3.0] = Matrix.get_col(matrix, 2) |> get_value()
  end

  test "swap_row/3", %{matrix: matrix} do
    matrix = Matrix.swap_row(matrix, 3, 5)
    assert [4.0, 3.0, 2.0, 3.0] = Matrix.get_row(matrix, 3) |> get_value()
    assert [3.0, 2.0, 3.0, 4.0] = Matrix.get_row(matrix, 5) |> get_value()
  end

  test "update_row/3", %{matrix: matrix} do
    matrix = Matrix.update_row(matrix, [%Matrix.Cell{x: 2, y: 1, value: Fraction.new(1)}])
    assert [1.0] == Matrix.get_row(matrix, 2) |> get_value()
  end

  test "max_abs_x_in_y/2", %{matrix: matrix} do
    assert 4 == Matrix.max_abs_x_in_y(matrix, 2)
    assert 1 == Matrix.max_abs_x_in_y(matrix, 4)
  end

  test "row_count/1", %{matrix: matrix} do
    assert 5 == Matrix.row_count(matrix)
  end

  defp get_value(cells) do
    Enum.map(cells, &Fraction.to_float(&1.value))
  end
end
