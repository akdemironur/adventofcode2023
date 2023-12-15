defmodule Day15 do
  def read_input(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split(",", trim: true)

      {:error, reason} ->
        raise "Oh no! #{reason}"
    end
  end

  def partA(file_path) do
    file_path
    |> read_input()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def partB(file_path) do
    file_path
    |> read_input()
    |> Enum.reduce(Enum.take(Stream.cycle([[]]), 256), &apply_op(&2, extract_op(&1)))
    |> total_focusing_power()
  end

  def hash(l), do: hash(String.to_charlist(l), 0)
  def hash([], acc), do: acc
  def hash([h | t], acc), do: hash(t, Integer.mod((acc + h) * 17, 256))

  def extract_op(str) do
    case Regex.named_captures(~r/(?<label>\w+)((=(?<number>\d+))|-)/, str) do
      %{"label" => label, "number" => number} when number != "" ->
        {label, {:add, String.to_integer(number)}}

      %{"label" => label} ->
        {label, {:remove}}
    end
  end

  def remove(box, label), do: Enum.reject(box, fn {l, _} -> l == label end)

  def add(box, label, value) do
    case Enum.find_index(box, fn {l, _} -> l == label end) do
      nil -> box ++ [{label, value}]
      idx -> List.replace_at(box, idx, {label, value})
    end
  end

  def apply_op_to_box(box, label, {:add, value}), do: add(box, label, value)
  def apply_op_to_box(box, label, {:remove}), do: remove(box, label)

  def apply_op(l, {label, op}) do
    Enum.at(l, hash(label))
    |> apply_op_to_box(label, op)
    |> (&List.replace_at(l, hash(label), &1)).()
  end

  def total_focusing_power(boxes) do
    Enum.with_index(boxes)
    |> Enum.flat_map(fn {box, box_index} ->
      Enum.with_index(box)
      |> Enum.map(fn {{_, focal_length}, lens_index} ->
        (box_index + 1) * (lens_index + 1) * focal_length
      end)
    end)
    |> Enum.sum()
  end
end

IO.puts(Day15.partA("./input"))
IO.puts(Day15.partB("./input"))
