Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def count_paths({x,y}, map, path) do
    neighbours = [
      {x+1,y},
      {x,y+1},
      {x-1,y},
      {x,y-1}
    ]

    neighbours
      |> Enum.filter(fn n ->
        if map[n] == nil do
          false
        else
          (map[n] - map[{x,y}]) == 1
        end
      end)
      |> Enum.flat_map(fn n ->
        if map[n] == 9 do
          [[n | path]]
        else
          count_paths(n, map, [n | path])
        end
      end)
      |> Enum.uniq()
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day10.txt")

{map, trail_heads} = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({%{}, []}, fn {line, y}, {map, trail_heads} ->
 line
 |> String.graphemes()
 |> Enum.map(fn x ->
  if (x == ".") do
    nil
  else
    String.to_integer(x)
  end
  end)
 |> Enum.with_index()
 |> Enum.reduce({map, trail_heads}, fn {s, x}, {map, trail_heads} ->
    n_trail_heads = if s == 0 do
      [{x,y} | trail_heads]
    else
      trail_heads
    end

    {Map.put(map, {x,y}, s), n_trail_heads}
  end)
end)

trail_heads
|> Enum.map(fn trail_head ->
  Funcs.count_paths(trail_head, map, [trail_head])
end)
|> Enum.map(&(Enum.count(&1)))
|> Enum.sum()
|> IO.inspect()



IO.puts(System.os_time(:millisecond) - start)
