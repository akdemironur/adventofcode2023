defmodule Day23 do
  def read_input(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> extract_start_end()
  end

  def extract_start_end(grid) do
    start_col = grid |> Enum.at(0) |> Enum.find_index(fn x -> x == "." end)
    end_col = grid |> Enum.at(-1) |> Enum.find_index(fn x -> x == "." end)
    end_row = length(grid) - 1

    %{
      map: grid |> Enum.map(&List.to_tuple/1) |> List.to_tuple(),
      start: {0, start_col},
      end: {end_row, end_col},
      nrows: grid |> length(),
      ncols: grid |> Enum.at(0) |> length()
    }
  end

  def create_map(%{nrows: nrows, ncols: ncols} = grid) do
    Enum.reduce(0..(nrows - 1), %{}, fn r, acc ->
      Enum.reduce(0..(ncols - 1), acc, fn c, acc ->
        if get({r, c}, grid) != "#" do
          neighbors = [
            {r - 1, c},
            {r + 1, c},
            {r, c - 1},
            {r, c + 1}
          ]

          reachable =
            Enum.filter(neighbors, fn {nr, nc} ->
              get({nr, nc}, grid) != "#"
            end)
            |> Enum.map(fn {nr, nc} -> {{nr, nc}, 1} end)

          Map.put(acc, {r, c}, reachable)
        else
          acc
        end
      end)
    end)
  end

  def eliminate_direct_node(map, node) do
    reachable = map[node]

    if length(reachable) == 2 do
      [{{n1, c1}, d1}, {{n2, c2}, d2}] = reachable

      map
      |> Map.update({n1, c1}, [], fn old ->
        [{{n2, c2}, d1 + d2} | old |> Enum.reject(fn {l, _d} -> l == node end)]
      end)
      |> Map.update({n2, c2}, [], fn old ->
        [{{n1, c1}, d1 + d2} | old |> Enum.reject(fn {l, _d} -> l == node end)]
      end)
      |> Map.delete(node)
    else
      map
    end
  end

  def eliminate_all(map) do
    case Enum.filter(map, fn {_, reach} -> length(reach) == 2 end) do
      [] -> map
      [{node, _} | _] -> eliminate_all(eliminate_direct_node(map, node))
    end
  end

  def get({r, c}, %{nrows: nrows, ncols: ncols}) when r < 0 or c < 0 or r >= nrows or c >= ncols,
    do: "#"

  def get({r, c}, %{map: map}), do: map |> elem(r) |> elem(c)

  def next_steps_partA({{r, c} = loc, seen, d}, grid) do
    new_seen = MapSet.put(seen, loc)

    case get(loc, grid) do
      "." -> [{r + 1, c}, {r - 1, c}, {r, c + 1}, {r, c - 1}]
      "v" -> [{r + 1, c}]
      "^" -> [{r - 1, c}]
      ">" -> [{r, c + 1}]
      "<" -> [{r, c - 1}]
      _ -> []
    end
    |> Enum.reject(fn l -> get(l, grid) == "#" or MapSet.member?(seen, l) end)
    |> Enum.map(fn l -> {l, new_seen, d + 1} end)
  end

  def longest_path(grid, fun), do: longest_path(grid, fun, [{grid[:start], MapSet.new(), 0}], 0)

  def longest_path(_, _, [], curr_max), do: curr_max

  def longest_path(grid, fun, [{loc, _, _} = s | rest], curr_max) do
    next_s = fun.(s, grid)

    next_max =
      if loc == grid[:end] do
        max(curr_max, elem(s, 2))
      else
        curr_max
      end

    longest_path(grid, fun, rest ++ next_s, next_max)
  end

  def longest_path(%{start: s} = graph) do
    longest_path(graph, [{s, MapSet.new(), 0}], 0)
  end

  def longest_path(_, [], curr_max), do: curr_max

  def longest_path(graph, [{loc, seen, dist} | rest], curr_max) do
    new_seen = MapSet.put(seen, loc)

    if(loc == graph[:end]) do
      longest_path(graph, rest, max(curr_max, dist))
    else
      reach =
        graph[:graph][loc]
        |> Enum.reject(fn {l, _} -> MapSet.member?(seen, l) end)
        |> Enum.map(fn {l, d} -> {l, new_seen, d + dist} end)

      longest_path(graph, reach ++ rest, curr_max)
    end
  end

  def partA(file_path) do
    file_path |> read_input() |> longest_path(&next_steps_partA/2)
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> (fn x -> %{start: x[:start], end: x[:end], graph: x |> create_map() |> eliminate_all()} end).()
    |> longest_path()
  end
end

IO.puts(Day23.partA("./input"))
IO.puts(Day23.partB("./input"))
