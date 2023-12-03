defmodule Day03 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(~r/\n/, trim: true)
        |> Enum.map(&to_charlist/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partA(file_path) do
    file_path |> read_input |> extract_part_numbers({0, 0}, 0, false, []) |> Enum.sum()
  end

  def partB(file_path) do
    board = file_path |> read_input
    extract_gear_locs(board) |> Enum.map(&get_gear_score(&1, board)) |> Enum.sum()
  end

  defp cell_type(val) do
    case val do
      46 -> :blank
      _ when val >= 48 and val <= 57 -> :number
      _ -> :symbol
    end
  end

  defp is_symbol({r, c}, board) do
    cell = board |> Enum.at(r, []) |> Enum.at(c, 46)

    case cell |> cell_type do
      :symbol -> true
      _ -> false
    end
  end

  defp is_adjacent_to_symbol({r, c}, board) do
    {r, c}
    |> adjacent_cells()
    |> Enum.map(&is_symbol(&1, board))
    |> Enum.any?()
  end

  defp adjacent_cells({r, c}) do
    for x <- [r, r + 1, r - 1],
        y <- [c, c + 1, c - 1],
        {x, y} != {r, c},
        do: {x, y}
  end

  defp extract_part_numbers(_, {140, 0}, _, _, part_numbers), do: part_numbers

  defp extract_part_numbers(board, {r, 140}, current_number, is_part_number, part_numbers) do
    if is_part_number do
      extract_part_numbers(board, {r + 1, 0}, 0, false, [current_number | part_numbers])
    else
      extract_part_numbers(board, {r + 1, 0}, 0, false, part_numbers)
    end
  end

  defp extract_part_numbers(board, {r, c}, current_number, is_part_number, part_numbers) do
    cell_val = board |> Enum.at(r) |> Enum.at(c)
    next_cell = {r, c + 1}

    case cell_type(cell_val) do
      :number ->
        extract_part_numbers(
          board,
          {r, c + 1},
          current_number * 10 + (cell_val - 48),
          is_part_number or is_adjacent_to_symbol({r, c}, board),
          part_numbers
        )

      _ ->
        if is_part_number do
          extract_part_numbers(board, next_cell, 0, false, [current_number | part_numbers])
        else
          extract_part_numbers(board, next_cell, 0, false, part_numbers)
        end
    end
  end

  defp extract_gear_locs(board) do
    board
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      for {value, c} <- Enum.with_index(row), value == 42, do: {r, c}
    end)
  end

  defp parse_charlist([]), do: []

  defp parse_charlist(cstr) do
    [cstr |> to_string |> String.to_integer()]
  end

  defp parse_ratios({r, c}, board) do
    row = Enum.at(board, r, [])

    left =
      Enum.slice(row, 0, c)
      |> Enum.reverse()
      |> Enum.take_while(fn x -> x >= 48 and x <= 57 end)
      |> Enum.reverse()

    right =
      Enum.slice(row, c + 1, 140)
      |> Enum.take_while(fn x -> x >= 48 and x <= 57 end)

    center = Enum.at(row, c, 46)

    if cell_type(center) == :number do
      parse_charlist(left ++ [center] ++ right)
    else
      parse_charlist(left) ++ parse_charlist(right)
    end
  end

  defp get_gear_score({r, c}, board) do
    all_numbers =
      parse_ratios({r, c}, board) ++
        parse_ratios({r + 1, c}, board) ++
        parse_ratios({r - 1, c}, board)

    if length(all_numbers) == 2 do
      Enum.product(all_numbers)
    else
      0
    end
  end
end

IO.puts(Day03.partA("./input"))
IO.puts(Day03.partB("./input"))
