defmodule Day18 do
  def read_input(file_path, line_parser) do
    File.read!(file_path)
    |> String.split("\n", trim: true)
    |> Enum.map(line_parser)
  end

  def solve(file_path, line_parser) do
    instr_list = read_input(file_path, line_parser)
    calcArea(instr_list) + div(instr_list |> Enum.map(&elem(&1, 1)) |> Enum.sum(), 2) + 1
  end

  def partA(file_path), do: solve(file_path, &partA_line_parser/1)
  def partB(file_path), do: solve(file_path, &partB_line_parser/1)

  def partA_line_parser(line) do
    [instr, d, _] = String.split(line, " ", trim: true)
    {instr, String.to_integer(d)}
  end

  @instrs %{"0" => "R", "1" => "D", "2" => "L", "3" => "U"}
  def partB_line_parser(line) do
    [_, _, hex] = String.split(line, ~r/\ |\(|\)|#/, trim: true)
    {d, instr_idx} = String.split_at(hex, -1)
    {@instrs[instr_idx], Integer.parse(d, 16) |> elem(0)}
  end

  def calcArea({"R", n}, {area, y}), do: {area + y * n, y}
  def calcArea({"L", n}, {area, y}), do: {area - y * n, y}
  def calcArea({"U", n}, {area, y}), do: {area, y + n}
  def calcArea({"D", n}, {area, y}), do: {area, y - n}

  def calcArea(instr_list) do
    instr_list
    |> Enum.reduce({0, 0}, fn instr, {area, y} -> calcArea(instr, {area, y}) end)
    |> elem(0)
  end
end

IO.puts(Day18.partA("./input"))
IO.puts(Day18.partB("./input"))
