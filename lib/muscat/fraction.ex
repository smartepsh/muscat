defmodule Muscat.Fraction do
  @moduledoc """
  This module provides some simple opertaions for fraction.
  """

  @type t :: %__MODULE__{
          numerator: integer(),
          denominator: integer() | nil,
          sign: :positive | :negative
        }

  defstruct [:numerator, :denominator, :sign]

  @doc """
  Creates a fraction.

  Both numerator and denominator are integers.(and the denominator can't be 0).

  It doesn't matter whether the sign of the fraction is at the numerator or denominator.

  ## About 0

  - If numerator is 0, the denominator in result is nil and sign is positive.
  - If denominator is 0, it will raise.

  ```
    Fraction.new(0, 1)   # %{numerator: 0, denominator: nil, sign: :positive}
    Fraction.new(1, 2)   # %{numerator: 1, denominator: 2, sign: :positive}
    Fraction.new(-1, -2) # %{numerator: 1, denominator: 2, sign: :positive}
    Fraction.new(-1, 2)  # %{numerator: -1, denominator: 2, sign: :negative}
  ```
  """
  @spec new(numerator :: integer(), denominator :: integer()) :: __MODULE__.t()
  def new(_numerator, 0) do
    raise ArgumentError, "The denominator can't be 0."
  end

  def new(0, denominator) when is_integer(denominator) do
    %__MODULE__{numerator: 0, denominator: nil, sign: :positive}
  end

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    sign =
      cond do
        numerator < 0 and denominator < 0 -> :positive
        numerator > 0 and denominator > 0 -> :positive
        true -> :negative
      end

    %__MODULE__{
      numerator: Kernel.abs(numerator),
      denominator: Kernel.abs(denominator),
      sign: sign
    }
  end

  def new(_, _) do
    raise ArgumentError, "Both numerator and denominator are integers."
  end
end
