defmodule Day22 do
  def read_input(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.map(&top_bot_layers/1)
    |> insert_bricks()
  end

  def parse(line) do
    [x1, y1, z1, x2, y2, z2] =
      line |> String.split(~r/(,)|(\~)|(\ )/, trim: true) |> Enum.map(&String.to_integer/1)

    {{z1, y1, x1}, {z2, y2, x2}, {z2 - z1, y2 - y1, x2 - x1}}
  end

  def get_zmax({_, y, x}, z_map), do: Map.get(z_map, {x, y}, -1)

  def top_bot_layers({{{z, y, x1}, {_z, _y, x2}, {0, 0, _}}, idx}) do
    top_bot =
      x1..x2
      |> Enum.map(fn x -> {z, y, x} end)

    %{top: top_bot, bot: top_bot, dz: 1, idx: idx}
  end

  def top_bot_layers({{{z, y1, x}, {_z, y2, _x}, {0, _, 0}}, idx}) do
    top_bot =
      y1..y2
      |> Enum.map(fn y -> {z, y, x} end)

    %{top: top_bot, bot: top_bot, dz: 1, idx: idx}
  end

  def top_bot_layers({{bot, top, {dz, 0, 0}}, idx}) do
    %{top: [top], bot: [bot], dz: dz + 1, idx: idx}
  end

  def shift_to_zm1(%{bot: bot, top: top, dz: dz} = b, zm) do
    new_bot = bot |> Enum.map(fn {_, y, x} -> {zm + 1, y, x} end)
    new_top = top |> Enum.map(fn {_, y, x} -> {zm + dz, y, x} end)
    b |> Map.put(:top, new_top) |> Map.put(:bot, new_bot)
  end

  def insert_bricks([], _, inserted_bricks), do: inserted_bricks

  def insert_bricks([b | bricks], z_map, inserted_bricks) do
    zm = b[:bot] |> Enum.map(&get_zmax(&1, z_map)) |> Enum.max()
    new_b = shift_to_zm1(b, zm)
    new_z_map = Enum.reduce(new_b[:top], z_map, fn {z, y, x}, acc -> Map.put(acc, {x, y}, z) end)
    insert_bricks(bricks, new_z_map, [new_b | inserted_bricks])
  end

  def insert_bricks(bricks), do: insert_bricks(bricks, Map.new(), [])

  def is_support_to(%{top: top}, %{bot: bot}) do
    Enum.any?(top, fn {z, y, x} -> Enum.member?(bot, {z + 1, y, x}) end)
  end

  def supports_of(brick, bricks) do
    {brick[:idx],
     bricks
     |> Enum.filter(fn b -> is_support_to(b, brick) end)
     |> Enum.map(fn %{idx: idx} -> idx end)}
  end

  def supports(bricks), do: bricks |> Enum.map(&supports_of(&1, bricks)) |> Map.new()

  def is_cone_to(a, b) do
    is_support_to(b, a)
  end

  def cones_of(brick, bricks) do
    {brick[:idx],
     bricks
     |> Enum.filter(fn b -> is_cone_to(b, brick) end)
     |> Enum.map(fn %{idx: idx} -> idx end)}
  end

  def cones(bricks), do: bricks |> Enum.map(&cones_of(&1, bricks)) |> Map.new()

  def partA(file_path) do
    bricks = file_path |> read_input()
    sup = supports(bricks) |> Enum.map(fn {_, x} -> x end)

    bricks
    |> Enum.reject(fn x -> Enum.member?(sup, [x[:idx]]) end)
    |> length()
  end

  def partB(file_path) do
    bricks = file_path |> read_input()
    sup = supports(bricks)
    con = cones(bricks)
    counts = sup |> Map.to_list() |> Enum.sort() |> Enum.map(fn {_, s} -> length(s) end)

    bricks
    |> Enum.map(fn x -> count_falls(con, counts, [x[:idx]], -1) end)
    |> Enum.sum()
  end

  def count_falls(_, _, [], acc), do: acc

  def count_falls(con, counts, [x | xs], acc) do
    nc = con[x] |> Enum.reduce(counts, fn s, c -> List.update_at(c, s, &(&1 - 1)) end)
    nx = con[x] |> Enum.filter(fn k -> Enum.at(nc, k) == 0 end)
    count_falls(con, nc, nx ++ xs, acc + 1)
  end
end

IO.puts(Day22.partA("./input"))
IO.puts(Day22.partB("./input"))
