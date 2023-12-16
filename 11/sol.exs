defmodule Day11 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.graphemes/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def get_val({row, col}, space), do: space |> Enum.at(row) |> Enum.at(col)

  def extract_empty_cols_index(space) do
    0..(length(Enum.at(space, 0)) - 1)
    |> Enum.filter(fn col ->
      0..(length(space) - 1)
      |> Enum.map(fn row -> {row, col} end)
      |> Enum.map(fn pos -> get_val(pos, space) end)
      |> Enum.all?(fn val -> val == "." end)
    end)
  end

  def extract_empty_rows_index(space) do
    0..(length(space) - 1)
    |> Enum.filter(fn row -> Enum.at(space, row) |> Enum.all?(fn val -> val == "." end) end)
  end

  def extract_galaxy_coords(space) do
    0..(length(space) - 1)
    |> Enum.flat_map(fn row ->
      0..(length(Enum.at(space, 0)) - 1)
      |> Enum.map(fn col -> {row, col} end)
    end)
    |> Enum.filter(fn {row, col} -> get_val({row, col}, space) != "." end)
  end

  def expanded_coord(row, expansion_rate, empty_rows) do
    empty_rows
    |> Enum.take_while(fn r -> r < row end)
    |> length()
    |> (fn l -> row + l * (expansion_rate - 1) end).()
  end

  def expanded_coord({row, col}, expansion_rate, empty_rows, empty_cols) do
    {expanded_coord(row, expansion_rate, empty_rows),
     expanded_coord(col, expansion_rate, empty_cols)}
  end

  def distance({row, col}, {row2, col2}) do
    abs(row2 - row) + abs(col2 - col)
  end

  def dist_of_combs([], acc), do: acc

  def dist_of_combs([coord | rest], acc) do
    dist_of_combs(
      rest,
      acc + (rest |> Enum.map(fn coord2 -> distance(coord, coord2) end) |> Enum.sum())
    )
  end

  def solve(file_path, exp_rate) do
    space = read_input(file_path)
    empty_rows = extract_empty_rows_index(space)
    empty_cols = extract_empty_cols_index(space)
    coords = extract_galaxy_coords(space)

    coords
    |> Enum.map(fn coord -> expanded_coord(coord, exp_rate, empty_rows, empty_cols) end)
    |> dist_of_combs(0)
  end

  def partA(file_path), do: solve(file_path, 2)
  def partB(file_path), do: solve(file_path, 1_000_000)
end

IO.puts(Day11.partA("./input"))
IO.puts(Day11.partB("./input"))
