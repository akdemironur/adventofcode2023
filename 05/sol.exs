defmodule Day05 do
  defp read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        sections = content |> String.split("\n\n", trim: true)

        seeds =
          sections
          |> Enum.at(0)
          |> String.split(" ", trim: true)
          |> tl
          |> Enum.map(&String.to_integer/1)

        maps = 1..7 |> Enum.map(&read_section_n(&1, sections))
        {seeds, maps}

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  defp read_section_n(n, sections) do
    sections
    |> Enum.at(n)
    |> String.split("\n", trim: true)
    |> Enum.slice(1..-1)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)
    |> Enum.sort_by(&Enum.at(&1, 1))
  end

  defp lookupRange([dst, src, sz], x) do
    if x >= src and x < src + sz do
      dst + (x - src)
    else
      nil
    end
  end

  defp lookupSectionH(section, [start, sz], acc) do
    droppedSection = Enum.drop_while(section, fn [_, src, sz] -> src + sz <= start end)

    case droppedSection do
      [] ->
        [[start, sz] | acc]

      [[dst, src, sz2] | _] ->
        if src > start do
          if src - start > sz do
            [[start, sz] | acc]
          else
            lookupSectionH(section, [src, sz - src + start], [[start, src - start] | acc])
          end
        else
          if src + sz2 > start + sz do
            [[dst + start - src, sz] | acc]
          else
            lookupSectionH(section, [src + sz2, sz - (sz2 - start + src)], [
              [dst + start - src, sz2 - start + src] | acc
            ])
          end
        end
    end
  end

  defp lookupSection(section, x) when is_integer(x) do
    lu =
      section
      |> Enum.map(&lookupRange(&1, x))
      |> Enum.filter(fn x -> x != nil end)

    case lu do
      [] -> x
      [a] -> a
    end
  end

  defp lookupSection(section, x) do
    x |> Enum.map(&lookupSectionH(section, &1, [])) |> Enum.concat()
  end

  defp lookupMap(map, x) do
    map |> Enum.reduce(x, &lookupSection(&1, &2))
  end

  def partA(file_path) do
    {seeds, maps} = read_input(file_path)
    seeds |> Enum.map(&lookupMap(maps, &1)) |> Enum.min()
  end

  def partB(file_path) do
    {seedRanges, maps} = read_input(file_path)
    lookupMap(maps, Enum.chunk_every(seedRanges, 2)) |> Enum.min_by(fn [x, _] -> x end) |> hd
  end
end

IO.puts(Day05.partA("./input"))
IO.puts(Day05.partB("./input"))
