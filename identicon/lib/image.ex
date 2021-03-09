defmodule Identicon.Image do
  defstruct hex: nil, color: nil, grid: nil, pixel_map: nil

   @typedoc """
      Type that represents Image struct with hex: nil, color: nil, grid: nil, pixel_map: nil, binary: nil
  """
  @type image(hex, color, grid, pixel_map) :: %Identicon.Image{hex: hex, color: color, grid: grid, pixel_map: pixel_map}
  @type image :: %Identicon.Image{hex: [], color: {}, grid: [], pixel_map: []}
end
