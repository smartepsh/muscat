defmodule Muscat.FractionTest do
  use ExUnit.Case

  alias Muscat.Fraction

  describe "new/1" do
    test "success" do
      assert %{numerator: 0, denominator: :any, sign: :positive} = Fraction.new(0)
      assert %{numerator: 2, denominator: 1, sign: :positive} = Fraction.new(2)
      assert %{numerator: 2, denominator: 1, sign: :negative} = Fraction.new(-2)
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new({1, 2})
    end
  end

  describe "new/2" do
    test "success" do
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new(1, 2)
      assert %{numerator: 1, denominator: 2, sign: :negative} = Fraction.new(-1, 2)
      assert %{numerator: 1, denominator: 2, sign: :negative} = Fraction.new(1, -2)
      assert %{numerator: 1, denominator: 2, sign: :positive} = Fraction.new(-1, -2)
    end

    test "success with numerator is 0" do
      assert %{numerator: 0, denominator: :any, sign: :positive} = Fraction.new(0, 2)
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

  describe "compare/2" do
    test "eq" do
      assert :eq == Fraction.compare(Fraction.new(1, 2), Fraction.new(1, 2))
      assert :eq == Fraction.compare(Fraction.new(1, 2), Fraction.new(2, 4))
    end

    test "lt" do
      assert :lt == Fraction.compare(Fraction.new(1, 2), Fraction.new(1))
      assert :lt == Fraction.compare(Fraction.new(-1, 2), Fraction.new(-1, 3))
    end

    test "gt" do
      assert :gt == Fraction.compare(Fraction.new(-1, 2), Fraction.new(-1))
      assert :gt == Fraction.compare(Fraction.new(-1, 3), Fraction.new(-1, 2))
    end
  end

  describe "reduce/1" do
    test "do nothing when fraction is 0" do
      assert %{numerator: 0, denominator: :any, sign: :positive} =
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

  describe "inverse/1 and reciprocal/1" do
    test "success" do
      assert %{numerator: 3, denominator: 1, sign: :negative} =
               Fraction.new(-1, 3) |> Fraction.inverse()

      assert %{numerator: 3, denominator: 1, sign: :negative} =
               Fraction.new(-1, 3) |> Fraction.reciprocal()

      assert %{numerator: 3, denominator: 1, sign: :positive} =
               Fraction.new(1, 3) |> Fraction.inverse()

      assert %{numerator: 3, denominator: 1, sign: :positive} =
               Fraction.new(1, 3) |> Fraction.reciprocal()
    end

    test "raises if numerator is 0" do
      assert_raise ArithmeticError, fn ->
        Fraction.new(0, 1) |> Fraction.inverse()
      end

      assert_raise ArithmeticError, fn ->
        Fraction.new(0, 1) |> Fraction.reciprocal()
      end
    end
  end

  describe "opposite/1" do
    test "do nothing when numerator is 0" do
      assert %{numerator: 0, denominator: :any, sign: :positive} = fraction = Fraction.new(0, 1)
      assert %{numerator: 0, denominator: :any, sign: :positive} = Fraction.opposite(fraction)
      assert %{numerator: 0, denominator: :any, sign: :positive} = Fraction.negate(fraction)
    end

    test "success" do
      assert %{numerator: 1, denominator: 3, sign: :negative} =
               Fraction.new(1, 3) |> Fraction.opposite()

      assert %{numerator: 1, denominator: 3, sign: :negative} =
               Fraction.new(1, 3) |> Fraction.negate()
    end
  end

  describe "add/2" do
    test "success" do
      assert %{numerator: 4, denominator: 6, sign: :positive} =
               Fraction.new(3, 6) |> Fraction.add(Fraction.new(1, 6))

      assert %{numerator: 5, denominator: 6, sign: :positive} =
               Fraction.new(1, 3) |> Fraction.add(Fraction.new(1, 2))

      assert %{numerator: 1, denominator: 6, sign: :positive} =
               Fraction.new(-1, 3) |> Fraction.add(Fraction.new(1, 2))

      assert %{numerator: 1, denominator: 6, sign: :negative} =
               Fraction.new(-1, 2) |> Fraction.add(Fraction.new(1, 3))
    end
  end

  describe "minus/2" do
    test "success" do
      assert %{numerator: 0, denominator: :any, sign: :positive} =
               Fraction.new(5, 6) |> Fraction.minus(Fraction.new(5, 6))

      assert %{numerator: 4, denominator: 6, sign: :positive} =
               Fraction.new(5, 6) |> Fraction.minus(Fraction.new(1, 6))

      assert %{numerator: 1, denominator: 6, sign: :negative} =
               Fraction.new(1, 3) |> Fraction.minus(Fraction.new(1, 2))
    end
  end

  describe "multi/2" do
    test "success" do
      assert %{numerator: 0, denominator: :any, sign: :positive} =
               Fraction.new(0) |> Fraction.multi(Fraction.new(1, 6))

      assert %{numerator: 0, denominator: :any, sign: :positive} =
               Fraction.new(1, 3) |> Fraction.multi(Fraction.new(0))

      assert %{numerator: 6, denominator: 36, sign: :positive} =
               Fraction.new(6, 6) |> Fraction.multi(Fraction.new(1, 6))

      assert %{numerator: 6, denominator: 36, sign: :negative} =
               Fraction.new(-6, 6) |> Fraction.multi(Fraction.new(1, 6))

      assert %{numerator: 6, denominator: 36, sign: :positive} =
               Fraction.new(-6, 6) |> Fraction.multi(Fraction.new(-1, 6))
    end
  end

  describe "divide/2" do
    test "raises ArithmeticError when denominator is zero fraction" do
      assert_raise ArithmeticError, fn ->
        Fraction.new(1, 2) |> Fraction.divide(Fraction.new(0))
      end
    end

    test "success" do
      assert %{numerator: 0, denominator: :any, sign: :positive} =
               Fraction.new(0) |> Fraction.divide(Fraction.new(1, 3))

      assert %{numerator: 36, denominator: 6, sign: :positive} =
               Fraction.new(6, 6) |> Fraction.divide(Fraction.new(1, 6))

      assert %{numerator: 36, denominator: 6, sign: :negative} =
               Fraction.new(-6, 6) |> Fraction.divide(Fraction.new(1, 6))

      assert %{numerator: 36, denominator: 6, sign: :positive} =
               Fraction.new(-6, 6) |> Fraction.divide(Fraction.new(-1, 6))
    end
  end

  describe "to_float/1" do
    test "returns 0.0 for zero fraction" do
      assert 0.0 == Fraction.new(0) |> Fraction.to_float()
    end

    test "returns normal result without round" do
      assert 0.3333333333333333 == Fraction.new(1, 3) |> Fraction.to_float()
    end

    test "returns normal result with round" do
      assert 0.33 == Fraction.new(1, 3) |> Fraction.to_float(precision: 2)
    end

    test "raises if precision not btw in 0 and 15" do
      assert_raise ArgumentError, fn ->
        Fraction.new(1, 3) |> Fraction.to_float(precision: -1)
      end

      assert_raise ArgumentError, fn ->
        Fraction.new(1, 3) |> Fraction.to_float(precision: 16)
      end
    end
  end
end
