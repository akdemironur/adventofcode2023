defmodule Day14 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.graphemes/1)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> tilt_and_rotate()
    |> calc_all_loads()
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> tilt_n_cycle(1_000_000_000)
    |> rotate()
    |> calc_all_loads()
  end

  def tilt_insert(x, []), do: [x]
  def tilt_insert("O", ["." | t]), do: ["." | tilt_insert("O", t)]
  def tilt_insert("O", ["#" | t]), do: ["O" | ["#" | t]]
  def tilt_insert(x, t), do: [x | t]

  def tilt(l) do
    Enum.reduce(l, [], fn x, acc -> tilt_insert(x, acc) end)
  end

  def tilt_and_rotate(ll), do: tilt_and_rotate(ll, [])
  def tilt_and_rotate([[] | _], acc), do: acc

  def tilt_and_rotate(l, acc) do
    heads = l |> Enum.map(&hd/1)
    tails = l |> Enum.map(&tl/1)
    tilt_and_rotate(tails, acc ++ [tilt(heads)])
  end

  def rotate(l), do: rotate(l, [])

  def rotate([[] | _], acc), do: acc

  def rotate(l, acc) do
    heads = l |> Enum.map(&hd/1)
    tails = l |> Enum.map(&tl/1)
    rotate(tails, acc ++ [Enum.reverse(heads)])
  end

  def calc_load(l) do
    Enum.with_index(l)
    |> Enum.reduce(0, fn {x, i}, acc -> if(x == "O", do: acc + i + 1, else: acc) end)
  end

  def calc_all_loads(ll), do: Enum.map(ll, &calc_load/1) |> Enum.sum()

  def tilt_1_cycle(ll), do: Enum.reduce(1..4, ll, fn _, acc -> tilt_and_rotate(acc) end)

  def tilt_n_cycle(ll, n), do: tilt_n_cycle(ll, n, %{})
  def tilt_n_cycle(ll, 0, _), do: ll

  def tilt_n_cycle(ll, m, memo) do
    new_m = if Map.has_key?(memo, ll), do: Integer.mod(m, memo[ll] - m), else: m
    tilt_n_cycle(tilt_1_cycle(ll), new_m - 1, Map.put(memo, ll, m))
  end
end

IO.puts(Day14.partA("./input"))
IO.puts(Day14.partB("./input"))
