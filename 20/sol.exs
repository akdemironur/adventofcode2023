defmodule Day20 do
  def read_input(file_path) do
    all_sources =
      File.read!(file_path)
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Map.new()

    Map.new(all_sources, &add_froms(&1, all_sources))
  end

  def partA(file_path), do: file_path |> read_input |> process_n_times(1000)
  def partB(file_path), do: file_path |> read_input |> process_until_track()

  def parse_line(line) do
    case String.split(line, ~r/\ |(->)|,/, trim: true) do
      ["broadcaster" = s | targets] ->
        {s, %{type: :broadcaster, to: targets}}

      [src | targets] ->
        {src_type, src_name} = String.split_at(src, 1)
        {src_name, %{type: type(src_type), to: targets}}
    end
  end

  def type("%"), do: :flipflop
  def type("&"), do: :conjunction
  @hi true
  @lo false
  def add_froms({name, m}, all_sources) do
    all_sources
    |> Map.filter(fn {_, %{to: t}} -> Enum.member?(t, name) end)
    |> Map.new(fn {key, _} -> {key, @lo} end)
    |> (fn s -> Map.put(m, :from, s) end).()
    |> (fn new_m -> {name, Map.put(new_m, :latest, @lo)} end).()
  end

  def process_signals(all_sources, [], hilo, track, _), do: {all_sources, hilo, track}

  def process_signals(all_sources, [s | rest], hilo, track, n) do
    process_signals(s, all_sources[elem(s, 1)], all_sources, rest, hilo, track, n)
  end

  def process_signals({_, "broadcaster", @lo}, m, all_sources, queue, {hi, lo}, track, n) do
    new_queue = m[:to] |> Enum.reduce(queue, fn t, acc -> acc ++ [{"broadcaster", t, @lo}] end)
    process_signals(all_sources, new_queue, {hi, lo + 1}, track, n)
  end

  def process_signals(
        {_from, _to, @hi},
        %{type: :flipflop},
        all_sources,
        queue,
        {hi, lo},
        track,
        n
      ),
      do: process_signals(all_sources, queue, {hi + 1, lo}, track, n)

  def process_signals(
        {_from, to, @lo},
        %{type: :flipflop, latest: state} = m,
        all_sources,
        queue,
        {hi, lo},
        track,
        n
      ) do
    new_queue = m[:to] |> Enum.reduce(queue, fn t, acc -> acc ++ [{to, t, not state}] end)
    new_source = Map.put(m, :latest, not state)
    new_all_sources = Map.put(all_sources, to, new_source)
    process_signals(new_all_sources, new_queue, {hi, lo + 1}, track, n)
  end

  def process_signals(
        {from, to, sig},
        %{type: :conjunction, from: f} = m,
        all_sources,
        queue,
        {hi, lo},
        track,
        n
      ) do
    new_f = Map.put(f, from, sig)
    new_source = Map.put(m, :from, new_f)
    new_all_sources = Map.put(all_sources, to, new_source)
    new_sig = not Enum.all?(new_f |> Map.values())
    new_queue = m[:to] |> Enum.reduce(queue, fn t, acc -> acc ++ [{to, t, new_sig}] end)

    new_track =
      if !sig and Map.has_key?(track, to) do
        Map.update(track, to, [n], fn l -> l ++ [n] end)
      else
        track
      end

    process_signals(
      new_all_sources,
      new_queue,
      {hi + ((sig && 1) || 0), lo + ((sig && 0) || 1)},
      new_track,
      n
    )
  end

  def process_signals({_, _, sig}, _, all_sources, queue, {hi, lo}, track, n),
    do:
      process_signals(
        all_sources,
        queue,
        {hi + ((sig && 1) || 0), lo + ((sig && 0) || 1)},
        track,
        n
      )

  def process_n_times({_, {hi, lo}, _}, 0), do: hi * lo

  def process_n_times({all_sources, hilo, track}, n),
    do:
      process_n_times(
        process_signals(all_sources, [{nil, "broadcaster", false}], hilo, track, 0),
        n - 1
      )

  def process_n_times(all_sources, n),
    do: process_n_times({all_sources, {0, 0}, Map.new()}, n)

  def tracking_list(all_sources) do
    rx_tx =
      all_sources
      |> Map.filter(fn {_, %{to: t}} -> Enum.member?(t, "rx") end)
      |> Map.keys()
      |> Enum.at(0)

    all_sources
    |> Map.filter(fn {_, %{to: t}} -> Enum.member?(t, rx_tx) end)
    |> Map.keys()
    |> Map.new(fn k -> {k, []} end)
  end

  def check_track(tracking_map) do
    tracking_map
    |> Map.values()
    |> Enum.all?(fn l -> length(l) >= 2 end)
  end

  def process_until_track(all_sources),
    do: process_until_track(all_sources, tracking_list(all_sources), 0)

  def process_until_track(all_sources, tracking_map, n) do
    {new_sources, _, new_track} =
      process_signals(all_sources, [{nil, "broadcaster", false}], {0, 0}, tracking_map, n)

    if check_track(new_track) do
      new_track
      |> Map.values()
      |> Enum.map(fn l -> Enum.at(l, 1) - Enum.at(l, 0) end)
      |> Enum.reduce(fn x, y -> div(x * y, Integer.gcd(x, y)) end)
    else
      process_until_track(new_sources, new_track, n + 1)
    end
  end
end

IO.puts(Day20.partA("./input"))
IO.puts(Day20.partB("./input"))
