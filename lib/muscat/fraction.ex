defmodule Muscat.Fraction do
  @moduledoc """
  This module provides some simple operations for fraction.
  """

  @type fraction_tuple :: {numerator :: integer(), denominator :: neg_integer() | pos_integer()}
  @type t :: %__MODULE__{
          numerator: integer(),
          denominator: integer() | :any,
          sign: :positive | :negative
        }

  defstruct [:numerator, :denominator, :sign]

  defguard is_zero_fraction(fraction)
           when is_struct(fraction, __MODULE__) and fraction.numerator == 0

  @doc """
  Creates a fraction from integer value or tuple.

  ```
  Fraction.new(2)
  #=> %{numerator: 2, denominator: 1, sign: :positive}

  Fraction.new(0)
  #=> %{numerator: 0, denominator: :any, sign: :positive}

  Fraction.new({1, 2})
  #=> %{numerator: 1, denominator: 2, sign: :positive}
  ```

  """
  @spec new(integer() | fraction_tuple()) :: __MODULE__.t()
  def new(value) when is_integer(value), do: new(value, 1)
  def new({numerator, denominator}), do: new(numerator, denominator)

  @doc """
  Creates a fraction with numerator and denominator.

  Both numerator and denominator are integers.(and the denominator can't be `0`).

  It doesn't matter whether the sign of the fraction is at the numerator or denominator.

  ## About 0

  - If numerator is `0`, the denominator in result is :any and sign is positive.
  - If denominator is `0`, it will raise.

  ```
  Fraction.new(0, 1)
  #=> %{numerator: 0, denominator: :any, sign: :positive}

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
  @spec new(numerator :: integer(), denominator :: neg_integer() | pos_integer()) ::
          __MODULE__.t()
  def new(_numerator, 0) do
    raise ArgumentError, "The denominator can't be 0."
  end

  def new(0, denominator) when is_integer(denominator) do
    %__MODULE__{numerator: 0, denominator: :any, sign: :positive}
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

    compare(fraction1, fraction2) == :eq
  end

  @doc """
  Compare two fractions with returning `:eq`, `:lt` and `:gt` .

  ```
  fraction1 = Fraction.new(1280, 2560)
  fraction2 = Fraction.new(1, 2)

  Fraction.equal?(fraction1, fraction2)
  #=> :eq
  ```

  """
  @spec compare(__MODULE__.t(), __MODULE__.t()) :: :gt | :lt | :eq
  def compare(%{sign: :positive}, %{sign: :negative}), do: :gt
  def compare(%{sign: :negative}, %{sign: :positive}), do: :lt

  def compare(
        %{numerator: numerator, denominator: denominator, sign: sign},
        %{numerator: numerator, denominator: denominator, sign: sign}
      ),
      do: :eq

  def compare(fraction1, fraction2) do
    fraction1 = reduce(fraction1)
    fraction2 = reduce(fraction2)

    case minus(fraction1, fraction2) do
      fraction when is_zero_fraction(fraction) -> :eq
      %{sign: :positive} -> :gt
      %{sign: :negative} -> :lt
    end
  end

  @doc """
  Reduce the fraction to the simplest.

  ```
  Fraction.new(1280, 2560)
  |> Fraction.reduce()
  #=> %{numerator: 1, denominator: 2, sign: :positive}
  ```

  """
  @spec reduce(__MODULE__.t()) :: __MODULE__.t()
  def reduce(fraction) when is_zero_fraction(fraction), do: fraction

  def reduce(%__MODULE__{numerator: numerator, denominator: denominator} = fraction) do
    max_common_divisor = Integer.gcd(numerator, denominator)

    %{
      fraction
      | numerator: div(numerator, max_common_divisor),
        denominator: div(denominator, max_common_divisor)
    }
  end

  @doc """
  Fraction `+` operation without reduction.

  ```
  Fraction.new(1, 2)
  |> Fraction.add(Fraction.new(1, 3))
  #=> %{numerator: 5, denominator: 6, sign: :positive}

  Fraction.new(2, 4)
  |> Fraction.add(Fraction.new(1, 3))
  #=> %{numerator: 10, denominator: 12, sign: :positive}
  ```

  """
  @spec add(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def add(fraction1, fraction2) when is_zero_fraction(fraction1), do: fraction2
  def add(fraction1, fraction2) when is_zero_fraction(fraction2), do: fraction1

  def add(
        %__MODULE__{denominator: denominator} = fraction1,
        %__MODULE__{denominator: denominator} = fraction2
      ) do
    numerator =
      signed_number(fraction1.sign).(fraction1.numerator) +
        signed_number(fraction2.sign).(fraction2.numerator)

    new(numerator, denominator)
  end

  def add(%__MODULE__{} = fraction1, %__MODULE__{} = fraction2) do
    numerator =
      signed_number(fraction1.sign).(fraction1.numerator * fraction2.denominator) +
        signed_number(fraction2.sign).(fraction2.numerator * fraction1.denominator)

    new(numerator, fraction1.denominator * fraction2.denominator)
  end

  defp signed_number(:positive), do: &Kernel.+/1
  defp signed_number(:negative), do: &Kernel.-/1

  @doc """
  Fraction `-` operation without reduction.

  ```
  Fraction.new(1, 3)
  |> Fraction.minus(Fraction.new(1, 2))
  #=> %{numerator: 1, denominator: 6, sign: :negative}

  Fraction.new(5, 6)
  |> Fraction.minus(Fraction.new(1, 6))
  #=> %{numerator: 4, denominator: 6, sign: :positive}
  ```

  """
  @spec minus(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def minus(fraction, fraction), do: new(0)

  def minus(fraction1, fraction2) do
    fraction2 |> opposite() |> add(fraction1)
  end

  @doc """
  Fraction `*` operation without reduction.

  ```
  Fraction.new(1, 3)
  |> Fraction.multi(Fraction.new(1, 2))
  #=> %{numerator: 1, denominator: 6, sign: :positive}

  Fraction.new(2, 3)
  |> Fraction.multi(Fraction.new(1, 6))
  #=> %{numerator: 2, denominator: 18, sign: :positive}
  ```

  """
  @spec multi(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def multi(fraction, _fraction2) when is_zero_fraction(fraction), do: new(0)
  def multi(_fraction1, fraction) when is_zero_fraction(fraction), do: new(0)

  def multi(fraction1, fraction2) do
    new(
      signed_number(fraction1.sign).(fraction1.numerator) *
        signed_number(fraction2.sign).(fraction2.numerator),
      fraction1.denominator * fraction2.denominator
    )
  end

  @doc """
  Fraction `/` operation without reduction.

  ```
  Fraction.new(1, 3)
  |> Fraction.divide(Fraction.new(1, 2))
  #=> %{numerator: 2, denominator: 3, sign: :positive}

  Fraction.new(2, 4)
  |> Fraction.divide(Fraction.new(1, 2))
  #=> %{numerator: 4, denominator: 4, sign: :positive}
  ```

  """
  @spec divide(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def divide(fraction, _fraction) when is_zero_fraction(fraction), do: fraction
  def divide(_fraction, fraction) when is_zero_fraction(fraction), do: raise(ArithmeticError)

  def divide(fraction1, fraction2) do
    fraction2 |> inverse() |> multi(fraction1)
  end

  @doc "Same to `inverse/1`"
  @spec reciprocal(__MODULE__.t()) :: __MODULE__.t()
  def reciprocal(fraction), do: inverse(fraction)

  @doc """
  Give the fraction reciprocal.

  If the given numerator is `0`, then raise `ArithmeticError`.

  ```
  Fraction.new(1, 2)
  |> Fraction.inverse()
  #=> %{numerator: 2, denominator: 1, sign: :positive}
  ```

  """
  @spec inverse(__MODULE__.t()) :: __MODULE__.t()
  def inverse(fraction) when is_zero_fraction(fraction),
    do: raise(ArithmeticError)

  def inverse(%__MODULE__{numerator: numerator, denominator: denominator} = fraction) do
    %{fraction | numerator: denominator, denominator: numerator}
  end

  @doc """
  Give the opposite fraction

  If the given numerator is `0`, returns fraction itself.

  ```
  Fraction.new(1, 2)
  |> Fraction.opposite()
  #=> %{numerator: 1, denominator: 2, sign: :negative}

  Fraction.new(0, 2)
  |> Fraction.opposite()
  #=> %{numerator: 0, denominator: :any, sign: :positive}
  ```

  """
  @spec opposite(__MODULE__.t()) :: __MODULE__.t()
  def opposite(fraction) when is_zero_fraction(fraction), do: fraction

  def opposite(%__MODULE__{sign: sign} = fraction) do
    %{fraction | sign: opposite_sign(sign)}
  end

  defp opposite_sign(:positive), do: :negative
  defp opposite_sign(:negative), do: :positive

  @doc "Same to `opposite/1`"
  @spec negate(__MODULE__.t()) :: __MODULE__.t()
  def negate(fraction), do: opposite(fraction)

  @doc "Return the absolute value of fraction."
  @spec abs(__MODULE__.t()) :: __MODULE__.t()
  def abs(%__MODULE__{sign: :positive} = fraction), do: fraction
  def abs(%__MODULE__{sign: :negative} = fraction), do: %{fraction | sign: :positive}

  @doc """
  Round a fraction to an arbitrary number of fractional digits.

  ### Options

  - `:precision` - between `0` and `15` . It uses `Float.round/2` to round.

  """
  @spec to_float(__MODULE__.t()) :: float()
  @spec to_float(__MODULE__.t(), opts :: [precision: non_neg_integer()]) :: float()
  def to_float(fraction, opts \\ [])
  def to_float(%__MODULE__{numerator: 0}, _opts), do: 0.0

  def to_float(%__MODULE__{numerator: numerator, denominator: denominator, sign: sign}, opts) do
    value = signed_number(sign).(numerator / denominator)

    case opts[:precision] do
      nil -> value
      precision when precision in 0..15 -> Float.round(value, precision)
      _ -> raise ArgumentError, "precision should be in 0..15"
    end
  end
end
