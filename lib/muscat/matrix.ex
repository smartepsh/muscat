defmodule Muscat.Matrix do
  alias Muscat.Fraction

  defmodule Cell do
    defstruct [:x, :y, :value]

    @type t :: %__MODULE__{x: integer(), y: integer(), value: Fraction.t() | :any}
  end

  def get_row(matrix, x) do
    Enum.filter(matrix, &(&1.x == x))
  end

  def get_col(matrix, y) do
    Enum.filter(matrix, &(&1.y == y))
  end

  def swap_row(matrix, x1, x2) do
    row_1 = matrix |> get_row(x1) |> Enum.map(&%{&1 | x: x2})
    row_2 = matrix |> get_row(x2) |> Enum.map(&%{&1 | x: x1})

    {_, others} = Enum.split_with(matrix, &(&1.x in [x1, x2]))

    others ++ row_1 ++ row_2
  end

  def update_row(matrix, [%{x: x} | _] = new_cells) do
    {_, others} = Enum.split_with(matrix, &(&1.x == x))

    others ++ new_cells
  end

  def max_abs_x_in_y(matrix, y) do
    %{x: x} =
      matrix
      |> get_col(y)
      |> Enum.max_by(&Fraction.abs(&1.value), Fraction)

    x
  end

  def row_count(matrix) do
    matrix |> Enum.uniq_by(& &1.x) |> length()
  end
end
