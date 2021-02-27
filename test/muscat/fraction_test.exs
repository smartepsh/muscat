defmodule Muscat.FractionTest do
  use ExUnit.Case

  alias Muscat.Fraction

  describe "new/2" do
    test "success" do
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new(1, 2)
      assert %{numerator: 1, denominator: 2, sign: :negative} = Fraction.new(-1, 2)
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new(-1, -2)
    end

    test "success with numerator is 0" do
      assert %{numerator: 0, denominator: nil, sign: :positive} = Fraction.new(0, 2)
    end

    test "raises if denominator is 0" do
      assert_raise ArgumentError, fn ->
        Fraction.new(1, 0)
      end
    end

    test "raises if not integer" do
      assert_raise ArgumentError, fn ->
        Fraction.new(1, "1")
      end

      assert_raise ArgumentError, fn ->
        Fraction.new(1, "1")
      end
    end
  end
end
