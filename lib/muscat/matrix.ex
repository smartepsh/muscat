defmodule Muscat.Matrix do
  alias Muscat.Fraction

  defmodule Cell do
    defstruct [:row, :col, :value]

    @type t :: %__MODULE__{row: integer(), col: integer(), value: Fraction.t() | :any}
  end

  def get_row(matrix, row) do
    matrix
    |> Enum.filter(&(&1.row == row))
    |> Enum.sort_by(& &1.col)
  end

  def get_col(matrix, col) do
    matrix
    |> Enum.filter(&(&1.col == col))
    |> Enum.sort_by(& &1.row)
  end

  def get_cell(matrix, row, col) do
    Enum.find(matrix, &(&1.row == row and &1.col == col))
  end

  def swap_row(matrix, row1, row2) do
    row_1 = matrix |> get_row(row1) |> Enum.map(&%{&1 | row: row2})
    row_2 = matrix |> get_row(row2) |> Enum.map(&%{&1 | row: row1})

    {_, others} = Enum.split_with(matrix, &(&1.row in [row1, row2]))

    others ++ row_1 ++ row_2
  end

  def update_row(matrix, [%{row: row} | _] = new_cells) do
    {_, others} = Enum.split_with(matrix, &(&1.row == row))

    others ++ new_cells
  end

  def update_col(matrix, [%{col: col} | _] = new_cells) do
    {_, others} = Enum.split_with(matrix, &(&1.col == col))

    others ++ new_cells
  end

  def remove_row(matrix, [%{row: row} | _]) do
    Enum.reject(matrix, &(&1.row == row))
  end

  def add_row(matrix, row_cells) do
    row_cells ++ matrix
  end

  def max_abs_row_in_col(matrix, col) do
    matrix
    |> get_col(col)
    |> Enum.max_by(&Fraction.abs(&1.value), Fraction, fn -> [] end)
    |> case do
      [] -> :no_data
      %{row: row} -> row
    end
  end

  def row_count(matrix) do
    matrix |> Enum.uniq_by(& &1.row) |> length()
  end

  def col_count(matrix) do
    matrix |> Enum.uniq_by(& &1.col) |> length()
  end

  def update_cell(cell, value_func \\ & &1) do
    value = value_func.(cell.value)
    %{cell | value: value}
  end
end
