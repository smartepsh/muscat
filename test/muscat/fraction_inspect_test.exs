defmodule Muscat.FractionInspectTest do
  use ExUnit.Case

  alias Muscat.Fraction

  test "for integer value" do
    assert "1" == Fraction.new(1) |> inspect()
  end

  test "for positive value" do
    assert "1/2" == Fraction.new(1, 2) |> inspect()
  end

  test "for negative value" do
    assert "-1/2" == Fraction.new(-1, 2) |> inspect()
    assert "-1/2" == Fraction.new(1, -2) |> inspect()
  end
end
