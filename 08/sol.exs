defmodule Day08 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        [directives | network_lines] =
          content
          |> String.split(~r/\n/, trim: true)

        {directives |> String.graphemes(), network_lines |> Enum.map(&parse/1) |> Map.new()}

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  defp parse(line) do
    [_, from, left, right] = Regex.run(~r/(\w+) = \((\w+), (\w+)\)/, line)
    {from, %{"L" => left, "R" => right}}
  end

  defp resolve(from, target, network, [], dir, acc),
    do: resolve(from, target, network, dir, dir, acc)

  defp resolve(from, target, network, [dir | rest], directives_all, acc) do
    if String.match?(from, target) do
      acc
    else
      resolve(network[from][dir], target, network, rest, directives_all, acc + 1)
    end
  end

  def partA(file_path) do
    {directives, network} = read_input(file_path)
    resolve("AAA", ~r/ZZZ/, network, directives, directives, 0)
  end

  def partB(file_path) do
    {directives, network} = read_input(file_path)

    Map.keys(network)
    |> Enum.filter(fn str -> String.ends_with?(str, "A") end)
    |> Enum.map(fn str ->
      resolve(str, ~r/Z\z/, network, directives, directives, 0)
    end)
    |> Enum.reduce(fn x, y -> div(x * y, Integer.gcd(x, y)) end)
  end
end

IO.puts(Day08.partA("./input"))
IO.puts(Day08.partB("./input"))
