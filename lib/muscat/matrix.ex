defmodule Muscat.Matrix do
  alias Muscat.Fraction

  defmodule Cell do
    defstruct [:x, :y, :value]

    @type t :: %__MODULE__{x: integer(), y: integer(), value: Fraction.t() | :any}
  end
end
