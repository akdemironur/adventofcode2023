defmodule Day24 do
  def read_input(file_path) do
    file_path |> File.read!() |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [px, py, pz, vx, vy, vz] =
      line |> String.split(~r/\ |,|@/, trim: true) |> Enum.map(&String.to_integer/1)

    m = vy / vx
    b = py - m * px
    %{vel: {vx, vy, vz}, pos: {px, py, pz}, m: m, b: b}
  end

  def valid_intersection_xy(
        %{
          pos: {pxa, _pya, _pza},
          vel: {vxa, _vya, _vza},
          m: ma,
          b: ba
        },
        %{
          pos: {pxb, _pyb, _pzb},
          vel: {vxb, _vyb, _vzb},
          m: mb,
          b: bb
        }
      ) do
    if abs(ma - mb) < 1.0e-8 do
      false
    else
      x = (bb - ba) / (ma - mb)
      y = ma * x + ba

      ta = (x - pxa) / vxa
      tb = (x - pxb) / vxb

      ta >= 0 and tb >= 0 and x >= 200_000_000_000_000 and x <= 400_000_000_000_000 and
        y >= 200_000_000_000_000 and y <= 400_000_000_000_000
    end
  end

  def count_intersections_xy(list), do: count_intersections_xy(list, 0)
  def count_intersections_xy([], acc), do: acc

  def count_intersections_xy([x | xs], acc) do
    count_intersections_xy(xs, acc + (xs |> Enum.count(&valid_intersection_xy(&1, x))))
  end

  def dot({a1, a2, a3}, {b1, b2, b3}), do: a1 * b1 + a2 * b2 + a3 * b3

  def cross({a1, a2, a3}, {b1, b2, b3}),
    do: {
      a2 * b3 - b2 * a3,
      a3 * b1 - b3 * a1,
      a1 * b2 - b1 * a2
    }

  def neg({a, b, c}), do: {-a, -b, -c}
  def add({a1, a2, a3}, {b1, b2, b3}), do: {a1 + b1, a2 + b2, a3 + b3}
  def sub(a, b), do: add(a, neg(b))
  def mult(m, {x, y, z}), do: {m * x, m * y, m * z}

  def plane(%{pos: p1, vel: v1}, %{pos: p2, vel: v2}) do
    p12 = sub(p1, p2)
    v12 = sub(v1, v2)
    vv = cross(v1, v2)
    {cross(p12, v12), dot(p12, vv)}
  end

  def rock(%{pos: p1, vel: v1} = h1, %{pos: p2, vel: v2} = h2, %{pos: _p3, vel: _v3} = h3) do
    {a, a_} = plane(h1, h2)
    {b, b_} = plane(h1, h3)
    {c, c_} = plane(h2, h3)
    w = mult(a_, cross(b, c)) |> add(mult(b_, cross(c, a))) |> add(mult(c_, cross(a, b)))
    t = dot(a, cross(b, c))
    w = mult(1 / t, w)
    w1 = sub(v1, w)
    w2 = sub(v2, w)
    ww = cross(w1, w2)
    e = dot(ww, cross(p2, w2))
    f = dot(ww, cross(p1, w1))
    g = dot(p1, ww)
    s = dot(ww, ww)
    mult(e / s, w1) |> add(mult(-f / s, w2)) |> add(mult(g / s, ww))
  end

  def partA(file_path) do
    # Somehow, partA works for my real input but fails on sample input, interesting. 
    file_path |> read_input() |> count_intersections_xy()
  end

  def partB(file_path) do
    [a, b, c | _] = file_path |> read_input()
    {x, y, z} = rock(a, b, c)
    round(x + y + z)
  end
end

IO.puts(Day24.partA("./input"))
IO.puts(Day24.partB("./input"))
