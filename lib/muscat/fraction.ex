defmodule Muscat.Fraction do
  @moduledoc """
  This module provides some simple operations for fraction.
  """

  @type t :: %__MODULE__{
          numerator: integer(),
          denominator: integer() | nil,
          sign: :positive | :negative
        }

  defstruct [:numerator, :denominator, :sign]

  @doc """
  Creates a fraction.

  Both numerator and denominator are integers.(and the denominator can't be `0`).

  It doesn't matter whether the sign of the fraction is at the numerator or denominator.

  ## About 0

  - If numerator is `0`, the denominator in result is nil and sign is positive.
  - If denominator is `0`, it will raise.

  ```
  Fraction.new(0, 1)
  #=> %{numerator: 0, denominator: nil, sign: :positive}

  Fraction.new(1, 2)
  #=> %{numerator: 1, denominator: 2, sign: :positive}

  Fraction.new(-1, -2)
  #=> %{numerator: 1, denominator: 2, sign: :positive}

  Fraction.new(-1, 2)
  #=> %{numerator: 1, denominator: 2, sign: :negative}

  Fraction.new(1, -2)
  #=> %{numerator: 1, denominator: 2, sign: :negative}
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

  @doc """
  Compare two fractions and returns `true` if they are equal, otherwise `false`.

  Fractions will be reduced first and then compared. It means `1/2` is equal to `2/4`.

  ```
  fraction1 = Fraction.new(1280, 2560)
  fraction2 = Fraction.new(1, 2)

  Fraction.equal?(fraction1, fraction2)
  #=> true
  ```

  """
  @spec equal?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def equal?(%__MODULE__{} = fraction1, %__MODULE__{} = fraction2) do
    fraction1 = reduce(fraction1)
    fraction2 = reduce(fraction2)
    do_equal?(fraction1, fraction2)
  end

  defp do_equal?(
         %{numerator: numerator, denominator: denominator, sign: sign},
         %{numerator: numerator, denominator: denominator, sign: sign}
       ),
       do: true

  defp do_equal?(_fraction1, _fraction2), do: false

  @doc """
  Reduce the fraction to the simplest.

  ```
  Fraction.new(1280, 2560)
  |> Fraction.reduce()
  #=> %{numerator: 1, denominator: 2, sign: :positive}
  ```

  """
  @spec reduce(__MODULE__.t()) :: __MODULE__.t()
  def reduce(%__MODULE__{numerator: 0} = fraction), do: fraction

  def reduce(%__MODULE__{numerator: numerator, denominator: denominator} = fraction) do
    max_common_divisor = Integer.gcd(numerator, denominator)

    %{
      fraction
      | numerator: div(numerator, max_common_divisor),
        denominator: div(denominator, max_common_divisor)
    }
  end
end
