#Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def neighbours() do
    [:east,:west,:south,:north]
  end

  def move({x,y}, dir) do
    case dir do
      :east -> {x+1,y}
      :west -> {x-1,y}
      :south -> {x,y+1}
      :north -> {x,y-1}
    end
  end

  def map_path({_prev, curr}, to, _walls) when curr == to do
    %{curr => 0}
  end

  def map_path({prev, curr}, to, walls) do
    neighbours()
    |> Enum.map(fn n -> move(curr, n) end)
    |> Enum.filter(fn n -> prev != n end)
    |> Enum.filter(fn n -> !MapSet.member?(walls, n) end)
    |> Enum.map(fn n ->
      paths = map_path({curr,n}, to, walls)
      Map.put(paths, curr, paths[n] + 1)
    end)
    |> Enum.reduce(%{}, fn m, acc ->
      Map.merge(m, acc, fn _k, x1, x2 -> min(x1,x2) end)
    end)
  end

  def find_path5({prev,curr,count},max,{max_x,max_y},path_cache, handled) do
    n_handled = MapSet.put(handled, {curr,count})
    nstuff = if count != 0 && Map.has_key?(path_cache, curr) do
      [{curr, path_cache[curr] + count}]
    else
      []
    end

    {n_handled, nstuff2} = if count < max do
      neighbours()
      |> Enum.map(fn n -> move(curr, n) end)
      |> Enum.filter(fn n -> prev != n end)
      |> Enum.filter(&(!MapSet.member?(handled,{&1,count+1})))
      |> Enum.filter(fn {x,y} -> x in 0..max_x && y in 0..max_y end)
      |> Enum.reduce({n_handled, nstuff}, fn n, {acc,acc2} ->
        {n_acc, n_acc2} = find_path5({curr,n,count+1},max,{max_x,max_y},path_cache,acc)
        {n_acc, n_acc2 ++ acc2}
      end)
    else
      {n_handled, nstuff}
    end

    {n_handled, nstuff2}
  end

  def find_path4(start, {max_x,max_y}, max_cheat, max_score, path_cache) do
    0..max_y
    |> Enum.flat_map(fn y ->
      0..max_x
      |> Enum.filter(fn x -> Map.has_key?(path_cache, {x,y}) end)
      |> Enum.map(fn x ->
        curr = {x,y}
        start_count = path_cache[start] - path_cache[curr]
        {_,found} = find_path5({nil,curr,0},max_cheat,{max_x,max_y},path_cache, MapSet.new())
        found
        |> Enum.map(fn {e,c} -> {start_count + c, curr, e} end)
        |> Enum.filter(fn {x,_,_} -> x <= max_score end)
        |> Enum.uniq_by(fn {_,y,x} -> {y,x} end)
        |> Enum.count()
      end)
    end)
  end
end

start_t = System.os_time(:millisecond)

input = File.read!("input/day20.txt")

{walls, start, ending} = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({MapSet.new(), nil, nil}, fn {line, y}, {walls, start, ending} ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce({walls, start, ending}, fn {s, x}, {walls, start, ending} ->
    case s do
      "#" -> {MapSet.put(walls, {x,y}), start, ending}
      "S" -> {walls, {x,y}, ending}
      "E" -> {walls, start, {x,y}}
      _ -> {walls, start, ending}
    end
  end)
end)

{max_x, max_y} = walls |> Enum.max_by(fn {x,y} -> x+y end)

path_map = Funcs.map_path({nil, start}, ending, walls)

min_score = path_map[start] |> IO.inspect()

Funcs.find_path4(start, {max_x,max_y}, 2, min_score - 100, path_map) |> Enum.sum() |> IO.inspect()
Funcs.find_path4(start, {max_x,max_y}, 20, min_score - 100, path_map) |> Enum.sum() |> IO.inspect()

IO.puts(System.os_time(:millisecond) - start_t)
