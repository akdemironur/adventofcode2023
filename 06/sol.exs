defmodule Day06 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&String.split(&1, ~r/ /, trim: true))
        |> Enum.map(&tl/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  defp ways_to_win(time, distance) do
    disc = :math.sqrt(time * time - 4 * distance)
    t1 = time + disc / 2
    t2 = time - disc / 2
    ceil(t1) - floor(t2) - 1
  end

  def partA(file_path) do
    read_input(file_path)
    |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)
    |> (fn [a, b] -> Enum.zip(a, b) end).()
    |> Enum.map(fn {t, d} -> ways_to_win(t, d) end)
    |> Enum.product()
  end

  def partB(file_path) do
    read_input(file_path)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.to_integer/1)
    |> (fn [t, d] -> ways_to_win(t, d) end).()
  end
end

IO.puts(Day06.partA("./input"))
IO.puts(Day06.partB("./input"))
