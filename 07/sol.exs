defmodule Day07 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&String.split(&1, ~r/ /, trim: true))
        |> Enum.map(fn [str, p] -> [str, String.to_integer(p)] end)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  @cards ~w[J 2 3 4 5 6 7 8 9 T O Q K A]
  defp hand(h) do
    card_points =
      h |> String.graphemes() |> Enum.map(fn x -> Enum.find_index(@cards, &(&1 == x)) end)

    freqs =
      @cards
      |> Enum.filter(fn x -> x != "O" end)
      |> Enum.map(&String.replace(h, "J", &1))
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&Enum.frequencies/1)
      |> Enum.map(&Map.values/1)
      |> Enum.map(&Enum.sort(&1, :desc))
      |> Enum.max()

    {freqs, card_points}
  end

  defp solve(hands_bids) do
    hands_bids
    |> Enum.map(fn [hand, bid] -> [elem(hand(hand), 0), elem(hand(hand), 1), bid] end)
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {[_, _, bid], i}, acc -> acc + bid * (i + 1) end)
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> Enum.map(fn [hand, bid] -> [String.replace(hand, "J", "O"), bid] end)
    |> solve()
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> solve()
  end
end

IO.puts(Day07.partA("./input"))
IO.puts(Day07.partB("./input"))
