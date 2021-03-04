defmodule Muscat.AugmentedMatrixTest do
  use ExUnit.Case

  alias Muscat.AugmentedMatrix

  describe "new/1" do
    test "success" do
      assert [
               %{x: 1, y: 1, value: %{numerator: 1, denominator: 1}},
               %{x: 1, y: 2, value: %{numerator: 2, denominator: 1}},
               %{x: 1, y: 3, value: %{numerator: 3, denominator: 1}},
               %{x: 2, y: 1, value: %{numerator: 4, denominator: 1}},
               %{x: 2, y: 2, value: %{numerator: 2, denominator: 4}},
               %{x: 2, y: 3, value: %{numerator: 2, denominator: 1}}
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
               %{x: 1, y: 1, value: %{numerator: 1, denominator: 1}},
               %{x: 1, y: 2, value: %{numerator: 2, denominator: 1}},
               %{x: 1, y: 3, value: %{numerator: 3, denominator: 1}},
               %{x: 2, y: 1, value: %{numerator: 4, denominator: 1}},
               %{x: 2, y: 2, value: %{numerator: 5, denominator: 1}},
               %{x: 2, y: 3, value: %{numerator: 6, denominator: 1}}
             ] = AugmentedMatrix.new([[1, 2], [4, 5]], [3, 6])
    end

    test "raises if the length of coefficient_matrix and constant_column is different" do
      assert_raise ArgumentError, fn ->
        AugmentedMatrix.new([[1, 2], [4, 5]], [4])
      end
    end
  end
end
