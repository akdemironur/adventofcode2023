defmodule Day04 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&read_line/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def read_line(str) do
    [_, b, c] =
      String.split(str, ~r/:|\|/, trim: true) |> Enum.map(&String.split(&1, " ", trim: true))

    {1, MapSet.new(Enum.map(b, &String.to_integer/1)),
     MapSet.new(Enum.map(c, &String.to_integer/1))}
  end

  def partA(file_path) do
    file_path
    |> read_input
    |> Enum.map(&number_of_matches/1)
    |> Enum.map(&point/1)
    |> Enum.sum()
  end

  def partB(file_path) do
    rem = file_path |> read_input

    add_duplicates(hd(rem), tl(rem), [])
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def number_of_matches({_, x, y}), do: MapSet.intersection(x, y) |> MapSet.size()

  def point(0), do: 0
  def point(num_of_matches), do: 2 ** (num_of_matches - 1)

  def add_to_next_N(0, _, l, acc), do: Enum.reverse(acc) ++ l
  def add_to_next_N(_, _, [], acc), do: Enum.reverse(acc)

  def add_to_next_N(n, val, [{a, b, c} | rest], acc) do
    add_to_next_N(n - 1, val, rest, [{a + val, b, c} | acc])
  end

  def add_duplicates(current_card, [], acc), do: Enum.reverse([current_card | acc])

  def add_duplicates({k, x, y}, remaining_cards, acc) do
    new_rem = add_to_next_N(number_of_matches({k, x, y}), k, remaining_cards, [])
    add_duplicates(hd(new_rem), tl(new_rem), [{k, x, y} | acc])
  end
end

IO.puts(Day04.partA("./input"))
IO.puts(Day04.partB("./input"))
