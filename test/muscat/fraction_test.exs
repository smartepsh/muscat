defmodule Muscat.FractionTest do
  use ExUnit.Case

  alias Muscat.Fraction

  describe "new/2" do
    test "success" do
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new(1, 2)
      assert %{numerator: 1, denominator: 2, sign: :negative} = Fraction.new(-1, 2)
      assert %{numerator: 1, denominator: 2, sign: :negative} = Fraction.new(1, -2)
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

  describe "equal?/2" do
    test "returns true" do
      assert true == Fraction.equal?(Fraction.new(1, 2), Fraction.new(1, 2))
      assert true == Fraction.equal?(Fraction.new(1, 2), Fraction.new(-1, -2))
      assert true == Fraction.equal?(Fraction.new(1, 2), Fraction.new(2, 4))
      assert true == Fraction.equal?(Fraction.new(0, 2), Fraction.new(0, 4))
    end

    test "returns false" do
      assert false == Fraction.equal?(Fraction.new(1, 2), Fraction.new(-1, 2))
      assert false == Fraction.equal?(Fraction.new(1, 2), Fraction.new(3, 4))
    end
  end

  describe "reduce/1" do
    test "do nothing when fraction is 0" do
      assert %{numerator: 0, denominator: nil, sign: :positive} =
               Fraction.new(0, 1) |> Fraction.reduce()
    end

    test "to the simplest positive fraction" do
      assert %{numerator: 1, denominator: 3, sign: :positive} =
               Fraction.new(1, 3) |> Fraction.reduce()

      assert %{numerator: 1, denominator: 2, sign: :positive} =
               Fraction.new(2, 4) |> Fraction.reduce()

      assert %{numerator: 1, denominator: 2, sign: :positive} =
               Fraction.new(1280, 2560) |> Fraction.reduce()
    end

    test "to the simplest negative fraction" do
      assert %{numerator: 1, denominator: 3, sign: :negative} =
               Fraction.new(-1, 3) |> Fraction.reduce()

      assert %{numerator: 1, denominator: 2, sign: :negative} =
               Fraction.new(-2, 4) |> Fraction.reduce()

      assert %{numerator: 1, denominator: 2, sign: :negative} =
               Fraction.new(-1280, 2560) |> Fraction.reduce()
    end
  end
end