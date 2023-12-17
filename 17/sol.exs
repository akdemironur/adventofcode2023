defmodule Day17 do
  def read_input(file_path) do
    File.read!(file_path)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.graphemes(line) |> Enum.map(&String.to_integer/1) end)
  end

  def apply_dir_to_pos({x, y}, {dx, dy}), do: {x + dx, y + dy}
  @dirs [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]

  def next_states(heatmap, {gridX, gridY}, costs, min_dist, max_dist, [
        {{{x, y}, _, dist}, _} | rest
      ])
      when x < 0 or y < 0 or gridX <= x or gridY <= y or dist > max_dist,
      do: next_states(heatmap, {gridX, gridY}, costs, min_dist, max_dist, rest)

  def next_states(heatmap, grid_lims, costs, min_dist, max_dist, [
        {{pos, dir, dist}, current_cost} | rest
      ]) do
    new_current_cost = (heatmap |> elem(elem(pos, 0)) |> elem(elem(pos, 1))) + current_cost

    if !(costs |> Map.get({pos, dir, dist}) <= new_current_cost) do
      new_costs = Map.put(costs, {pos, dir, dist}, new_current_cost)

      new_pos_dir_dists =
        if dist < min_dist do
          [
            {{apply_dir_to_pos(pos, Enum.at(@dirs, dir)), dir, dist + 1}, new_current_cost}
            | rest
          ]
        else
          [
            {{apply_dir_to_pos(pos, Enum.at(@dirs, dir)), dir, dist + 1}, new_current_cost}
            | [
                {{apply_dir_to_pos(pos, Enum.at(@dirs, Integer.mod(dir + 1, 4))),
                  Integer.mod(dir + 1, 4), 1}, new_current_cost}
                | [
                    {{apply_dir_to_pos(pos, Enum.at(@dirs, Integer.mod(dir + 3, 4))),
                      Integer.mod(dir + 3, 4), 1}, new_current_cost}
                    | rest
                  ]
              ]
          ]
        end

      next_states(
        heatmap,
        grid_lims,
        new_costs,
        min_dist,
        max_dist,
        new_pos_dir_dists
      )
    else
      next_states(heatmap, grid_lims, costs, min_dist, max_dist, rest)
    end
  end

  def next_states(_, _, costs, _, _, []), do: costs

  def next_states(heatmap, min_dist, max_dist),
    do:
      next_states(
        heatmap |> Enum.map(&List.to_tuple/1) |> List.to_tuple(),
        {length(heatmap), length(Enum.at(heatmap, 0))},
        %{},
        min_dist,
        max_dist,
        [{{{0, 1}, 3, 1}, 0}]
      )

  def solve(hm, min_dist, max_dist) do
    hm
    |> next_states(min_dist, max_dist)
    |> Map.to_list()
    |> Enum.map(fn {{{x, y}, _, dist}, cost} -> {{x, y, dist}, cost} end)
    |> Enum.filter(fn {{x, y, dist}, _} ->
      dist >= min_dist and x == length(hm) - 1 and y == length(Enum.at(hm, 0)) - 1
    end)
    |> Enum.map(fn {{_, _, _}, cost} -> cost end)
    |> Enum.min()
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> solve(1, 3)
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> solve(4, 10)
  end
end

IO.puts(Day17.partA("./input"))
IO.puts(Day17.partB("./input"))
