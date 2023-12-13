defmodule Day13 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n\n", trim: true)
        |> Enum.map(&String.split(&1, "\n", trim: true))
        |> Enum.map(fn l -> Enum.map(l, &String.graphemes/1) end)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> Enum.map(&find_mirror(&1, 0))
    |> Enum.map(&mirror_point/1)
    |> Enum.sum()
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> Enum.map(&find_mirror(&1, 1))
    |> Enum.map(&mirror_point/1)
    |> Enum.sum()
  end

  def pairs(mirror_loc, offset), do: {mirror_loc - 1 - offset, mirror_loc + offset}
  def get_row(arr, row_id), do: arr |> Enum.at(row_id)
  def get_col(arr, col_id), do: arr |> Enum.map(&Enum.at(&1, col_id)) |> List.flatten()

  def number_of_mismatches_at_offset(pattern, mirror_loc, offset, get_fun) do
    {p1, p2} = pairs(mirror_loc, offset)
    slice1 = get_fun.(pattern, p1)
    slice2 = get_fun.(pattern, p2)

    Enum.zip(slice1, slice2)
    |> Enum.filter(fn {a, b} -> a != b end)
    |> length()
  end

  def valid_mirror?(pattern, mirror_loc, type, target) do
    {get_fun, lim_fun} =
      case type do
        :row -> {&get_row/2, &get_col/2}
        :col -> {&get_col/2, &get_row/2}
      end

    0..(min(mirror_loc, length(lim_fun.(pattern, 0)) - mirror_loc) - 1)
    |> Enum.map(&number_of_mismatches_at_offset(pattern, mirror_loc, &1, get_fun))
    |> Enum.sum()
    |> Kernel.==(target)
  end

  def find_mirrorH(pattern, type, target) do
    lim_fun =
      case type do
        :row -> &get_col/2
        :col -> &get_row/2
      end

    Enum.reduce(
      1..(length(lim_fun.(pattern, 0)) - 1),
      nil,
      fn mirror_loc, acc ->
        case acc do
          nil -> if valid_mirror?(pattern, mirror_loc, type, target), do: mirror_loc, else: nil
          _ -> acc
        end
      end
    )
  end

  def find_mirror(pattern, target) do
    case find_mirrorH(pattern, :row, target) do
      nil -> {:col, find_mirrorH(pattern, :col, target)}
      x -> {:row, x}
    end
  end

  def mirror_point({:row, x}), do: 100 * x
  def mirror_point({:col, x}), do: x
end

IO.puts(Day13.partA("./input"))
IO.puts(Day13.partB("./input"))
