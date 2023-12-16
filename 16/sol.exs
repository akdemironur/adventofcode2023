defmodule Day16 do
  def read_input(file_path) do
    File.read!(file_path)
    |> String.split("\n", trim: true)
  end

  def interact(x, "."), do: [x]
  def interact({x, 0}, "|"), do: [{x, 0}]
  def interact(_, "|"), do: [{1, 0}, {-1, 0}]
  def interact({0, x}, "-"), do: [{0, x}]
  def interact(_, "-"), do: [{0, 1}, {0, -1}]
  def interact({x, y}, "/"), do: [{-y, -x}]
  def interact({x, y}, "\\"), do: [{y, x}]

  def get_contraption(grid, {x, y}) do
    case grid |> Enum.at(x) do
      nil -> nil
      line -> String.at(line, y)
    end
  end

  def apply_vel_to_pos({x, y}, {dx, dy}), do: %{pos: {x + dx, y + dy}, vel: {dx, dy}}

  def next_steps(%{pos: pos, vel: vel}, grid) do
    case get_contraption(grid, pos) do
      nil -> []
      contr -> Enum.map(interact(vel, contr), &apply_vel_to_pos(pos, &1))
    end
  end

  def iterate(grid, posvel),
    do:
      iterate(
        grid,
        [posvel],
        MapSet.new(),
        {length(grid), String.length(Enum.at(grid, 0))}
      )

  def iterate(_, [], visited_with_vel, _) do
    MapSet.to_list(visited_with_vel) |> Enum.map(fn x -> x[:pos] end) |> Enum.uniq() |> length()
  end

  def iterate(grid, [%{pos: {x, y}, vel: vel} | rest], visited_with_vel, {gridX, gridY})
      when x < 0 or x >= gridX or y < 0 or y >= gridY do
    iterate(grid, rest, visited_with_vel, {gridX, gridY})
  end

  def iterate(grid, [x | rest], visited_with_vel, lims) do
    visited_with_vel_next = MapSet.put(visited_with_vel, x)

    new_steps =
      next_steps(x, grid)
      |> Enum.reject(&MapSet.member?(visited_with_vel_next, &1))

    iterate(grid, new_steps ++ rest, visited_with_vel_next, lims)
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> iterate(%{pos: {0, 0}, vel: {0, 1}})
  end

  def partB(file_path) do
    grid = file_path |> read_input()
    gridX = grid |> length()
    gridY = grid |> Enum.at(0) |> String.length()
    possStartTop = Enum.map(0..(gridY - 1), fn y -> %{pos: {0, y}, vel: {1, 0}} end)
    possStartBot = Enum.map(0..(gridY - 1), fn y -> %{pos: {gridX - 1, y}, vel: {-1, 0}} end)
    possStartLeft = Enum.map(0..(gridX - 1), fn x -> %{pos: {x, 0}, vel: {0, 1}} end)
    possStartRight = Enum.map(0..(gridX - 1), fn x -> %{pos: {x, gridY - 1}, vel: {0, -1}} end)

    (possStartTop ++ possStartBot ++ possStartLeft ++ possStartRight)
    |> Enum.map(&iterate(grid, &1))
    |> Enum.max()
  end
end

IO.puts(Day16.partA("./input"))
IO.puts(Day16.partB("./input"))
