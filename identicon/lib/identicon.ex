defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.

  This module creates a PNG identicon based on an input string and saves it into the hard drive.
  """

  @doc """
  Creates the identicon by calling helper methods.

  ## Examples

      iex> Identicon.main("example")
      :ok

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Transforms a string input into a hexadecimal hash.

    Returns an Image struct with a list of the hexadecimal hash.

  ## Examples

      iex> Identicon.hash_input("example")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,
        51],
        pixel_map: nil
      }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

   @doc """
    Picks the color of the image based on the first 3 values of the hex list.

    Returns an Image struct with the color value populated.

  ## Examples

      iex> Identicon.pick_color(%Identicon.Image{color: nil,grid: nil,hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,51],pixel_map: nil})
      %Identicon.Image{
        color: {26, 121, 164},
        grid: nil,
        hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51],
        pixel_map: nil
      }
  """
  def pick_color( %Identicon.Image{hex: [r, g, b | _tail ]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Generates a 3x5 grid with each value indexed.

    Returns an Image struct with the grid value populated

  ## Examples

      iex> Identicon.build_grid(%Identicon.Image{color: {26, 121, 164},grid: nil,hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,51],pixel_map: nil})
      %Identicon.Image{
        color: {26, 121, 164},
        grid: [{26, 0},{121, 1},{164, 2},{121, 3},{26, 4},{214, 5},{13, 6},{230, 7},{13, 8},{214, 9},{113, 10},{142, 11},{142, 12},{142, 13},{113, 14},{91, 15},{50, 16},{110, 17},{50, 18},{91, 19},{51, 20},{138, 21},{229, 22},{138, 23},{51, 24}],
        hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51],
        pixel_map: nil
      }
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3,3, :discard)
      |> Enum.map(&mirrow_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Mirrows the two first element of each row.

    Returns a row with 5 elements.

  ## Examples

      iex> Identicon.mirrow_row([26, 121, 164])
      [26, 121, 164, 121, 26]
  """
  def mirrow_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  @doc """
    Updates the grid by filtering the odd values.

    Returns an Image struct with the updated grid.

  ## Examples

      iex> Identicon.filter_odd_squares(%Identicon.Image{color: {26, 121, 164},grid: [{26, 0},{121, 1},{164, 2},{121, 3},{26, 4},{214, 5},{13, 6},{230, 7},{13, 8},{214, 9},{113, 10},{142, 11},{142, 12},{142, 13},{113, 14},{91, 15},{50, 16},{110, 17},{50, 18},{91, 19},{51, 20},{138, 21},{229, 22},{138, 23},{51, 24}],hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,51],pixel_map: nil})
      %Identicon.Image{
        color: {26, 121, 164},
        grid: [{26, 0},{164, 2},{26, 4},{214, 5},{230, 7},{214, 9},{142, 11},{142, 12},{142, 13},{50, 16},{110, 17},{50, 18},{138, 21},{138, 23}],
        hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51],
        pixel_map: nil
      }
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code,2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Builds the pixel map by calculating the top-left point and the bottom-right point of each square.

    Returns an Image struct with the pixel_map value populated

  ## Examples

      iex> Identicon.build_pixel_map(%Identicon.Image{color: {26, 121, 164},grid: [{26, 0},{164, 2},{26, 4},{214, 5},{230, 7},{214, 9},{142, 11},{142, 12},{142, 13},{50, 16},{110, 17},{50, 18},{138, 21},{138, 23}],hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,51],pixel_map: nil})
      %Identicon.Image{
        color: {26, 121, 164},
        grid: [{26, 0},{164, 2},{26, 4},{214, 5},{230, 7},{214, 9},{142, 11},{142, 12},{142, 13},{50, 16},{110, 17},{50, 18},{138, 21},{138, 23}],
        hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51],
        pixel_map: [{{0, 0}, {50, 50}},{{100, 0}, {150, 50}},{{200, 0}, {250, 50}},{{0, 50}, {50, 100}},{{100, 50}, {150, 100}},{{200, 50}, {250, 100}},{{50, 100}, {100, 150}},{{100, 100}, {150, 150}},{{150, 100}, {200, 150}},{{50, 150}, {100, 200}},{{100, 150}, {150, 200}},{{150, 150}, {200, 200}},{{50, 200}, {100, 250}},{{150, 200}, {200, 250}}]
      }
  """
  def build_pixel_map(%Identicon.Image{grid: grid}= image)do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Draws the image by using the pixel_map and the color values in the struct.

    Returns the image's binary

  ## Examples

      Identicon.draw_image(%Identicon.Image{color: {26, 121, 164},grid: [{26, 0},{164, 2},{26, 4},{214, 5},{230, 7},{214, 9},{142, 11},{142, 12},{142, 13},{50, 16},{110, 17},{50, 18},{138, 21},{138, 23}],hex: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229,51], pixel_map: [{{0, 0}, {50, 50}},{{100, 0}, {150, 50}},{{200, 0}, {250, 50}},{{0, 50}, {50, 100}},{{100, 50}, {150, 100}},{{200, 50}, {250, 100}},{{50, 100}, {100, 150}},{{100, 100}, {150, 150}},{{150, 100}, {200, 150}},{{50, 150}, {100, 200}},{{100, 150}, {150, 200}},{{150, 150}, {200, 200}},{{50, 200}, {100, 250}},{{150, 200}, {200, 250}}]})
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start,stop, fill)
    end

    :egd.render(image)
  end

   @doc """
    Saves the image in the hard drive.

    Returns :ok

  ## Examples

      Identicon.save_image(binary)
  """
  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
