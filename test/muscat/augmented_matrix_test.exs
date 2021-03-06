defmodule Muscat.AugmentedMatrixTest do
  use ExUnit.Case

  alias Muscat.AugmentedMatrix

  describe "new/1" do
    test "success" do
      assert [
               %{row: 1, col: 1, value: %{numerator: 1, denominator: 1}},
               %{row: 1, col: 2, value: %{numerator: 2, denominator: 1}},
               %{row: 1, col: 3, value: %{numerator: 3, denominator: 1}},
               %{row: 2, col: 1, value: %{numerator: 4, denominator: 1}},
               %{row: 2, col: 2, value: %{numerator: 2, denominator: 4}},
               %{row: 2, col: 3, value: %{numerator: 2, denominator: 1}}
             ] = AugmentedMatrix.new([[1, 2, 3], [4, {2, 4}, 2]])
    end

    test "raises if the length of each rows is different" do
      assert_raise ArgumentError, fn ->
        AugmentedMatrix.new([[1, 2, 3], [4, 5, 6, 7]])
      end
    end

    test "raises if any rows is not list" do
      assert_raise ArgumentError, fn ->
        AugmentedMatrix.new([[1, 2, 3], 4])
      end
    end
  end

  describe "new/2" do
    test "success" do
      assert [
               %{row: 1, col: 1, value: %{numerator: 1, denominator: 1}},
               %{row: 1, col: 2, value: %{numerator: 2, denominator: 1}},
               %{row: 1, col: 3, value: %{numerator: 3, denominator: 1}},
               %{row: 2, col: 1, value: %{numerator: 4, denominator: 1}},
               %{row: 2, col: 2, value: %{numerator: 5, denominator: 1}},
               %{row: 2, col: 3, value: %{numerator: 6, denominator: 1}}
             ] = AugmentedMatrix.new([[1, 2], [4, 5]], [3, 6])
    end

    test "raises if the length of coefficient_matrix and constant_column is different" do
      assert_raise ArgumentError, fn ->
        AugmentedMatrix.new([[1, 2], [4, 5]], [4])
      end
    end
  end

  describe "rref/1" do
    test "success" do
      assert [1.0] == AugmentedMatrix.new([[1, 1]]) |> AugmentedMatrix.rref()

      assert [11.0, -8.0, -6.0, -7.0] ==
               AugmentedMatrix.new([
                 [2, -2, 2, 6, -16],
                 [2, -1, 2, 4, -10],
                 [3, -1, 4, 4, -11],
                 [1, 1, -1, 3, -12]
               ])
               |> AugmentedMatrix.rref()

      assert [4.0, 1.0, -2.0] ==
               AugmentedMatrix.new([
                 [1, 2, 3, 0],
                 [3, 4, 7, 2],
                 [6, 5, 9, 11]
               ])
               |> AugmentedMatrix.rref()
    end

    test "returns infinite_solutions" do
      assert {:error, :infinite_solutions} ==
               AugmentedMatrix.new([
                 [-2, -2, 2, -2, 2, -2],
                 [1, -5, 1, -1, -3, -1],
                 [-1, 2, -5, 5, 6, 2],
                 [-1, 2, 1, -1, 0, 0]
               ])
               |> AugmentedMatrix.rref()
    end

    test "returns approximate_solution" do
      assert {:error, :approximate_solutions} ==
               AugmentedMatrix.new([
                 [4, 3, 3],
                 [0, 2, 5],
                 [0, 0, 8]
               ])
               |> AugmentedMatrix.rref()
    end

    test "returns no_solution" do
      assert {:error, :no_solution} =
               AugmentedMatrix.new([
                 [3, 4, 2],
                 [0, 0, 1]
               ])
               |> AugmentedMatrix.rref()

      assert {:error, :no_solution} =
               AugmentedMatrix.new([
                 [1, 2, 3, 0],
                 [0, 0, 0, 2]
               ])
               |> AugmentedMatrix.rref()
    end
  end
end
