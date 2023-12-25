defmodule Day21 do
  def read_input(file_path) do
    grid =
      File.read!(file_path)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    {{grid
      |> Enum.map(fn l -> Enum.map(l, fn c -> if c == "S", do: ".", else: c end) end)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple(), {length(grid), length(Enum.at(grid, 0))}}, starting_point_index(grid)}
  end

  def starting_point_index(grid) do
    {row, ax} =
      grid
      |> Enum.with_index()
      |> Enum.find(fn {row, _index} -> Enum.member?(row, "S") end)

    {ax, row |> Enum.find_index(&(&1 == "S"))}
  end

  def get_val({x, y}, {_, {gridX, gridY}}) when x < 0 or y < 0 or x >= gridX or y >= gridY,
    do: nil

  def get_val({x, y}, {grid, _}) do
    elem(grid, x) |> elem(y)
  end

  def possible_steps_partA({ax, ay}, grid) do
    [{ax, ay - 1}, {ax, ay + 1}, {ax - 1, ay}, {ax + 1, ay}]
    |> Enum.filter(fn a -> get_val(a, grid) == "." end)
  end

  def possible_steps_partB({ax, ay}, {_, {gridX, gridY}} = g) do
    [{ax, ay - 1}, {ax, ay + 1}, {ax - 1, ay}, {ax + 1, ay}]
    |> Enum.filter(fn {x, y} ->
      get_val({Integer.mod(x, gridX), Integer.mod(y, gridY)}, g) == "."
    end)
  end

  def bfs(_, 0, queue, _), do: queue

  def bfs(grid, steps, queue, step_fun) do
    queue
    |> Enum.map(&step_fun.(&1, grid))
    |> List.flatten()
    |> Enum.uniq()
    |> (&bfs(grid, steps - 1, &1, step_fun)).()
  end

  def partA(file_path) do
    {grid, starting_point} = read_input(file_path)
    bfs(grid, 64, [starting_point], &possible_steps_partA/2) |> length()
  end

  @k 26_501_365
  def partB(file_path) do
    {{_, {gridX, _}} = g, starting_point} = read_input(file_path)
    n = Integer.mod(@k, gridX)
    f_n = bfs(g, n, [starting_point], &possible_steps_partB/2) |> length()
    f_nx = bfs(g, n + gridX, [starting_point], &possible_steps_partB/2) |> length()
    f_n2x = bfs(g, n + 2 * gridX, [starting_point], &possible_steps_partB/2) |> length()
    x = div(@k, gridX)

    # a_2 * x^2 + a_1 * x + a_0
    # |0 0 1| |a_2|   | f_n |
    # |1 1 1| |a_1| = | f_nx|
    # |4 2 1| |a_0|   |f_n2x|

    a_0 = f_n
    a_2 = div(f_n2x - 2 * f_nx + f_n, 2)
    a_1 = div(4 * f_nx - f_n2x - 3 * f_n, 2)

    a_0 + a_1 * x + a_2 * x * x
  end
end

IO.puts(Day21.partA("./input"))
IO.puts(Day21.partB("./input"))
