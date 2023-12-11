defmodule Day10 do
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

  def starting_point_index(grid) do
    {row, ax} =
      grid
      |> Enum.with_index()
      |> Enum.find(fn {row, _index} -> Enum.member?(row, "S") end)

    {ax, row |> Enum.find_index(&(&1 == "S"))}
  end

  @up {-1, 0}
  @down {1, 0}
  @left {0, -1}
  @right {0, 1}
  @dirs [@up, @down, @left, @right]
  def transform(@right, "-"), do: @right
  def transform(@right, "7"), do: @down
  def transform(@right, "J"), do: @up
  def transform(@left, "-"), do: @left
  def transform(@left, "F"), do: @down
  def transform(@left, "L"), do: @up
  def transform(@down, "|"), do: @down
  def transform(@down, "L"), do: @right
  def transform(@down, "J"), do: @left
  def transform(@up, "|"), do: @up
  def transform(@up, "F"), do: @right
  def transform(@up, "7"), do: @left
  def transform(_, _), do: nil

  def valid_start_dirs(grid, {ax, ay}) do
    @dirs
    |> Enum.filter(fn {dx, dy} ->
      ax + dx >= 0 and ax + dx < length(Enum.at(grid, 0)) and ay + dy >= 0 and
        ax + dy < length(grid) and
        transform({dx, dy}, grid |> Enum.at(ax + dx) |> Enum.at(ay + dy)) != nil
    end)
  end

  def traverse(grid, grid2, {sx, sy}, {px, py}, {cx, cy}, {dx, dy}, acc)
      when {sx, sy} != {cx, cy} or {px, py} == {nil, nil} do
    updated_grid2 =
      if grid2 != nil do
        grid2 |> List.replace_at(cx, List.replace_at(Enum.at(grid2, cx), cy, true))
      else
        nil
      end

    traverse(
      grid,
      updated_grid2,
      {sx, sy},
      {cx, cy},
      {cx + dx, cy + dy},
      transform({dx, dy}, grid |> Enum.at(cx + dx) |> Enum.at(cy + dy)),
      acc + 1
    )
  end

  def traverse(_, grid2, _, _, _, _, acc), do: {grid2, div(acc, 2)}

  def intersect_line([], _, _, acc), do: acc

  def intersect_line([true | xs], [r | row], flip, acc) do
    if(Enum.member?(["L", "J", "|"], r)) do
      intersect_line(xs, row, not flip, acc)
    else
      intersect_line(xs, row, flip, acc)
    end
  end

  def intersect_line([false | xs], [_ | row], true, acc),
    do: intersect_line(xs, row, true, acc + 1)

  def intersect_line([false | xs], [_ | row], false, acc),
    do: intersect_line(xs, row, false, acc)

  def intersect_grid([], _, acc), do: acc

  def intersect_grid([border | border_rest], [row | grid_rest], acc) do
    intersect_grid(border_rest, grid_rest, intersect_line(border, row, false, acc))
  end

  def partA(file_path) do
    grid = read_input(file_path)
    sp = starting_point_index(grid)
    [dir | _] = valid_start_dirs(grid, sp)
    {_, res} = traverse(grid, nil, sp, {nil, nil}, sp, dir, 0)
    res
  end

  def partB(file_path) do
    grid = read_input(file_path)

    empty_borders =
      List.duplicate(false, length(grid |> Enum.at(0))) |> List.duplicate(length(grid))

    sp = starting_point_index(grid)
    [dir | _] = valid_start_dirs(grid, sp)
    {borders, _} = traverse(grid, empty_borders, sp, {nil, nil}, sp, dir, 0)
    intersect_grid(borders, grid, 0)
  end
end

IO.puts(Day10.partA("./input"))
IO.puts(Day10.partB("./input"))
