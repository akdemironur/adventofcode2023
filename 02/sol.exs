defmodule Day02 do
  def partA(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&parse_line/1)
        |> Enum.filter(fn x -> is_valid_game(x.batches) end)
        |> Enum.map(fn x -> x.gameId end)
        |> Enum.sum()

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partB(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        String.split(String.slice(content, 0..-2//1), ~r/\n/)
        |> Enum.map(&parse_line/1)
        |> Enum.map(&min_required_bag/1)
        |> Enum.map(&Enum.product/1)
        |> Enum.sum()

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  defp parse_line(line) do
    {game_id, batches} =
      line
      |> String.split(": ")
      |> (fn [game_id_str, moves_str] ->
            {String.to_integer(String.slice(game_id_str, 5..-1//1)), moves_str}
          end).()

    batches =
      batches
      |> String.split("; ")
      |> Enum.map(&parse_batch/1)
      |> Enum.map(&Map.new/1)

    %{
      gameId: game_id,
      batches: batches
    }
  end

  @bag %{red: 12, green: 13, blue: 14}
  defp is_valid_batch(batch) do
    Enum.all?(batch, fn {color, val} -> Map.get(@bag, color) >= val end)
  end

  defp is_valid_game(game) do
    Enum.all?(game, &is_valid_batch/1)
  end

  defp parse_batch(batch) do
    batch
    |> String.split(", ")
    |> Enum.map(&parse_color_quantity/1)
  end

  defp min_required_bag(game) do
    [:red, :green, :blue]
    |> Enum.map(&min_required_color(&1, game))
  end

  defp min_required_color(color, %{gameId: _, batches: batches}) do
    batches
    |> Enum.map(&Map.get(&1, color, 0))
    |> Enum.max()
  end

  defp parse_color_quantity(cstr) do
    [nstr, color] = String.split(cstr, " ")
    {String.to_atom(color), String.to_integer(nstr)}
  end
end

IO.puts(Day02.partA("./input"))
IO.puts(Day02.partB("./input"))
