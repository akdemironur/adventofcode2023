defmodule Day12 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_line/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def parse_line(line) do
    [conditions, groups] = String.split(line, " ")
    conditions = String.graphemes(conditions)
    groups = String.split(groups, ",") |> Enum.map(&String.to_integer/1)
    {conditions, groups}
  end

  def partA(file_path) do
    read_input(file_path)
    |> Enum.map(&solve(&1, %{}, 0, {0, 0, 0}))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def partB(file_path) do
    read_input(file_path)
    |> Enum.map(fn {conditions, groups} ->
      {conditions |> List.duplicate(5) |> Enum.intersperse("?") |> List.flatten(),
       groups |> List.duplicate(5) |> List.flatten()}
    end)
    |> Enum.map(&solve(&1, %{}, 0, {0, 0, 0}))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def solve(_, memo, _, key) when is_map_key(memo, key), do: {memo, memo[key]}

  def solve({conditions, groups}, memo, acc, {id_conditions, id_groups, current_length})
      when length(conditions) == id_conditions do
    {memo,
     case {current_length, length(groups), length(groups) - 1, Enum.at(groups, id_groups)} do
       {0, ^id_groups, _, _} -> acc + 1
       {_, _, ^id_groups, ^current_length} -> acc + 1
       {_, _, _, _} -> acc
     end}
  end

  def solve({conditions, groups}, memo, acc, key) do
    {memo, acc}
    |> solveH(".", conditions, groups, key)
    |> solveH("#", conditions, groups, key)
    |> (fn {memop, res} -> {Map.put(memop, key, res), res} end).()
  end

  def solveH({memo, acc}, c, conditions, groups, {id_conditions, id_groups, current_length}) do
    cond do
      (Enum.at(conditions, id_conditions) == c or Enum.at(conditions, id_conditions) == "?") and
        c == "." and
          current_length == 0 ->
        solve({conditions, groups}, memo, 0, {id_conditions + 1, id_groups, 0})

      (Enum.at(conditions, id_conditions) == c or Enum.at(conditions, id_conditions) == "?") and
        c == "." and
        current_length > 0 and length(groups) > id_groups and
          Enum.at(groups, id_groups) == current_length ->
        solve({conditions, groups}, memo, 0, {id_conditions + 1, id_groups + 1, 0})

      (Enum.at(conditions, id_conditions) == c or Enum.at(conditions, id_conditions) == "?") and
          c == "#" ->
        solve({conditions, groups}, memo, 0, {id_conditions + 1, id_groups, current_length + 1})

      true ->
        {memo, 0}
    end
    |> (fn {memo, res} -> {memo, res + acc} end).()
  end
end

IO.puts(Day12.partA("./input"))
IO.puts(Day12.partB("./input"))
