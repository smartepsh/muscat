defmodule Muscat.FractionInspect do
  defimpl Inspect, for: Muscat.Fraction do
    @doc false
    def inspect(fraction, _opts) do
      sign =
        case fraction.sign do
          :positive -> ""
          :negative -> "-"
        end

      number =
        if fraction.denominator == 1 do
          Integer.to_string(fraction.numerator)
        else
          "#{fraction.numerator}/#{fraction.denominator}"
        end

      sign <> number
    end
  end
end
