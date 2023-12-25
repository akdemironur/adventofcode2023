defmodule Day01 do
  defp solve(file_path, map) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&extract_calibration_value(&1, map))
        |> Enum.sum()

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partA(file_path), do: solve(file_path, conversion_list_only_digits())
  def partB(file_path), do: solve(file_path, conversion_list_whole())

  def conversion_list_only_digits do
    1..9
    |> Enum.map(&Integer.to_string/1)
    |> Enum.with_index(1)
  end

  def conversion_list_whole do
    ~w(one two three four five six seven eight nine)
    |> Enum.with_index(1)
    |> (&(conversion_list_only_digits() ++ &1)).()
  end

  def extract_calibration_value("", _), do: 0

  def extract_calibration_value(string, map) do
    first_digit = find_first_matching_value(string, map)

    last_digit =
      find_first_matching_value(
        String.reverse(string),
        Enum.map(map, fn {key, val} -> {String.reverse(key), val} end)
      )

    first_digit * 10 + last_digit
  end

  def find_first_matching_value("", _), do: nil

  def find_first_matching_value(string, map) do
    case check_matching(string, map) do
      nil -> find_first_matching_value(String.slice(string, 1..-1//1), map)
      val -> val
    end
  end

  defp check_matching(_, []), do: nil

  defp check_matching(string, [{key, val} | rest]) do
    if String.starts_with?(string, key) do
      val
    else
      check_matching(string, rest)
    end
  end
end

IO.puts(Day01.partA("./input"))
IO.puts(Day01.partB("./input"))
