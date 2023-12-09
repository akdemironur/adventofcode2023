defmodule Day09 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, " ", trim: true))
        |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  defp extrapolate(xs) do
    if Enum.all?(xs, fn x -> x == 0 end) do
      0
    else
      0..(length(xs) - 2)
      |> Enum.map(fn i -> Enum.at(xs, i + 1) - Enum.at(xs, i) end)
      |> (&(hd(Enum.take(xs, -1)) + extrapolate(&1))).()
    end
  end

  def partA(file_path) do
    read_input(file_path)
    |> Enum.map(&extrapolate/1)
    |> Enum.sum()
  end

  def partB(file_path) do
    read_input(file_path)
    |> Enum.map(&extrapolate(Enum.reverse(&1)))
    |> Enum.sum()
  end
end

IO.puts(Day09.partA("./input"))
IO.puts(Day09.partB("./input"))
