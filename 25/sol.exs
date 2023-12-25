defmodule Day25 do
  def read_input(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> add_to_graph()
  end

  def parse_line(line) do
    [from | rest] = line |> String.split(~r/\ |:/, trim: true)
    {from, rest}
  end

  def add_to_graph(l), do: add_to_graph(l, Map.new())
  def add_to_graph([], graph), do: graph

  def add_to_graph([{from, tos} | rest], graph) do
    ng = Map.update(graph, from, tos, fn l -> l ++ tos end)

    add_to_graph(
      rest,
      tos |> Enum.reduce(ng, fn t, g -> Map.update(g, t, [from], fn l -> [from | l] end) end)
    )
  end

  def reach(graph, set) do
    Enum.reduce(set, MapSet.new(), fn k, acc -> MapSet.new(graph[k]) |> MapSet.union(acc) end)
    |> MapSet.reject(&MapSet.member?(set, &1))
  end

  def number_of_outer_connections(graph, set) do
    r = reach(graph, set)

    Enum.reduce(r, 0, fn v, acc ->
      (graph[v] |> Enum.filter(&MapSet.member?(set, &1)) |> length()) + acc
    end)
  end

  def put_vertex(graph, {vs, es}, v) do
    new_es =
      ((es |> Enum.reject(fn {_, t} -> t == v end)) ++
         (graph[v] |> Enum.reject(&MapSet.member?(vs, &1)) |> Enum.map(&{v, &1})))
      |> MapSet.new()

    new_vs = MapSet.put(vs, v)

    {new_vs, new_es}
  end

  def solve(graph) do
    first = graph |> Enum.at(0) |> elem(0)
    first_con = graph[first]
    initial_edges = first_con |> Enum.map(&{first, &1}) |> MapSet.new()

    solve(
      graph,
      [{MapSet.new([first]), initial_edges}],
      MapSet.new()
    )
  end

  def solve(graph, [{v, e} | sets], seen) do
    new_seen = seen |> MapSet.put(v)

    case MapSet.size(e) do
      3 ->
        (map_size(graph) - MapSet.size(v)) * MapSet.size(v)

      _ ->
        r = e |> Enum.map(&elem(&1, 1)) |> Enum.dedup()

        new_s =
          r
          |> Enum.map(&put_vertex(graph, {v, e}, &1))
          |> Enum.reject(&MapSet.member?(new_seen, elem(&1, 0)))
          |> Enum.sort_by(&MapSet.size(MapSet.difference(elem(&1, 1), e)))

        solve(graph, new_s ++ sets, new_seen)
    end
  end

  def partA(file_path) do
    file_path |> read_input() |> solve()
  end
end

IO.puts(Day25.partA("./input"))
