defmodule Day19 do
  def read_input(file_path) do
    [workflows_str, parts_str] =
      File.read!(file_path)
      |> String.split("\n\n", trim: true)

    parts =
      parts_str
      |> String.split("\n", trim: true)
      |> Enum.map(
        &(Regex.named_captures(~r/{x=(?<x>\d+),m=(?<m>\d+),a=(?<a>\d+),s=(?<s>\d+)}/, &1)
          |> Enum.map(fn {x, y} -> {x, String.to_integer(y)} end)
          |> Map.new())
      )

    workflows =
      workflows_str
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_workflow/1)
      |> Map.new()

    {workflows, parts}
  end

  def parse_workflow(line) do
    [operation | rules] = String.split(line, ~r/{|}/, trim: true)
    rules = String.split(Enum.at(rules, 0), ",")
    default_destination = String.trim(Enum.at(rules, -1))
    rules = Enum.slice(rules, 0..-2//1)

    rules =
      Enum.map(rules, fn rule ->
        parsed = Regex.named_captures(~r/(?<key>\w+)(?<check>[<>])(?<value>\d+):(?<to>\w+)/, rule)
        value = String.to_integer(parsed["value"])

        %{
          check:
            if(parsed["check"] == "<",
              do: &Kernel.<(&1[parsed["key"]], value),
              else: &Kernel.>(&1[parsed["key"]], value)
            ),
          to: parsed["to"],
          key: parsed["key"],
          fun:
            if(parsed["check"] == "<",
              do: :less_than,
              else: :greater_than
            ),
          value: value
        }
      end)

    {operation, %{rules: rules, default_destination: default_destination}}
  end

  def process_workflow(workflows, workflow, part),
    do: process_workflow(workflows, workflow[:rules], workflow[:default_destination], part)

  def process_workflow(workflows, [], default_destination, part) do
    case(default_destination) do
      "A" -> true
      "R" -> false
      trg -> process_workflow(workflows, workflows[trg], part)
    end
  end

  def process_workflow(workflows, [rule | rest], default_destination, part) do
    if(rule[:check].(part)) do
      case rule[:to] do
        "A" -> true
        "R" -> false
        trg -> process_workflow(workflows, workflows[trg], part)
      end
    else
      process_workflow(workflows, rest, default_destination, part)
    end
  end

  def partA(file_path) do
    {workflows, parts} = read_input(file_path)

    parts
    |> Enum.filter(fn part -> process_workflow(workflows, workflows["in"], part) end)
    |> Enum.map(fn part -> part["x"] + part["m"] + part["a"] + part["s"] end)
    |> Enum.sum()
  end

  def partB(file_path) do
    {workflows, _} = read_input(file_path)
    dr = %{h: 4000, l: 1}

    distinct_combs(workflows, [%{:loc => "in", "x" => dr, "m" => dr, "a" => dr, "s" => dr}], 0)
  end

  def distinct_combs(_, [], acc), do: acc

  def distinct_combs(
        workflows,
        [
          %{
            "x" => %{h: xh, l: xl},
            "m" => %{h: mh, l: ml},
            "a" => %{h: ah, l: al},
            "s" => %{h: sh, l: sl}
          }
          | rest
        ],
        acc
      )
      when xl > xh or ml > mh or al > ah or sl > sh,
      do: distinct_combs(workflows, rest, acc)

  def distinct_combs(
        workflows,
        [
          %{
            :loc => "A",
            "x" => %{h: xh, l: xl},
            "m" => %{h: mh, l: ml},
            "a" => %{h: ah, l: al},
            "s" => %{h: sh, l: sl}
          }
          | rest
        ],
        acc
      ),
      do:
        distinct_combs(
          workflows,
          rest,
          acc + (xh - xl + 1) * (mh - ml + 1) * (ah - al + 1) * (sh - sl + 1)
        )

  def distinct_combs(workflows, [%{loc: "R"} | rest], acc),
    do: distinct_combs(workflows, rest, acc)

  def distinct_combs(workflows, [curr_range | rest], acc) do
    new_r =
      new_ranges(
        workflows[curr_range[:loc]][:rules],
        workflows[curr_range[:loc]][:default_destination],
        curr_range,
        []
      )

    distinct_combs(workflows, new_r ++ rest, acc)
  end

  def new_ranges([], default_destination, range, acc),
    do: [Map.put(range, :loc, default_destination) | acc]

  def new_ranges([rule | rest], default_destination, range, acc) do
    key_range = range[rule[:key]]

    {true_key_range, false_key_range} =
      if rule[:fun] == :greater_than do
        {%{h: key_range[:h], l: max(key_range[:l], rule[:value] + 1)},
         %{h: min(key_range[:h], rule[:value]), l: key_range[:l]}}
      else
        {%{h: min(key_range[:h], rule[:value] - 1), l: key_range[:l]},
         %{h: key_range[:h], l: max(key_range[:l], rule[:value])}}
      end

    true_range = Map.put(range, rule[:key], true_key_range) |> Map.put(:loc, rule[:to])
    false_range = Map.put(range, rule[:key], false_key_range)
    [true_range | new_ranges(rest, default_destination, false_range, acc)]
  end
end

IO.puts(Day19.partA("./input"))
IO.puts(Day19.partB("./input"))
