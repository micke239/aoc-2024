Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def traverse({guard_x, guard_y}, _, _, acc, max_x, max_y) when (guard_x > max_x or guard_x < 0 or guard_y > max_y or guard_y < 0) do
    {acc, :success}
  end
  def traverse({guard_x, guard_y}, obstructions, direction, acc, max_x, max_y) do
    if (MapSet.member?(acc, {{guard_x, guard_y}, direction})) do
      {acc, :loop}
    else
      acc = MapSet.put(acc, {{guard_x, guard_y}, direction})

      n_pos = case direction do
        :up -> {guard_x, guard_y-1}
        :down -> {guard_x, guard_y+1}
        :right -> {guard_x+1, guard_y}
        :left -> {guard_x-1, guard_y}
      end

      {n_dir, n_pos} = case {MapSet.member?(obstructions, n_pos), direction} do
        {false, :up} -> {direction, {guard_x, guard_y-1}}
        {false, :down} -> {direction, {guard_x, guard_y+1}}
        {false, :right} -> {direction, {guard_x+1, guard_y}}
        {false, :left} -> {direction, {guard_x-1, guard_y}}
        {true, :up} -> {:right, {guard_x, guard_y}}
        {true, :right} -> {:down, {guard_x, guard_y}}
        {true, :down} -> {:left, {guard_x, guard_y}}
        {true, :left} -> {:up, {guard_x, guard_y}}
      end

      traverse(n_pos, obstructions, n_dir, acc, max_x, max_y)
    end
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day6.txt")

{obstructions, guard_pos} = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({%MapSet{}, nil}, fn {line, y}, {obstructions, guard_pos} ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce({obstructions, guard_pos}, fn {s, x}, {obstructions, guard_pos} ->
    case s do
      "#" -> {obstructions |> MapSet.put({x,y}), guard_pos}
      "^" -> {obstructions, {x,y}}
      _ -> {obstructions, guard_pos}
    end
  end)
end)

max_x = obstructions |> Enum.map(&(elem(&1, 0))) |> Enum.max()
max_y = obstructions |> Enum.map(&(elem(&1, 1))) |> Enum.max()

{acc, visits} = Funcs.traverse(guard_pos, obstructions, :up, %MapSet{}, max_x, max_y)

visited_points = acc
|> Enum.map(&(elem(&1, 0)))
|> Enum.uniq()

#part1
visited_points |> Enum.count() |> IO.inspect()

#part2
visited_points
|> Enum.filter(&(guard_pos != &1))
|> Enum.count(fn point ->
  {_, status} = Funcs.traverse(guard_pos, obstructions |> MapSet.put(point), :up, %MapSet{}, max_x, max_y)
  status == :loop
end)
|> IO.inspect()




IO.puts(System.os_time(:millisecond) - start)
