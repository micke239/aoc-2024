Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def test_operators({point_x,point_y}, _, acc, max_x, max_y) when point_x < 0 or point_x > max_x or point_y < 0 or point_y > max_y do
    acc
  end
  def test_operators({point_x,point_y}, {diff_x,diff_y}, acc, max_x, max_y) do
    test_operators({point_x + diff_x, point_y + diff_y}, {diff_x,diff_y}, [{point_x,point_y} | acc], max_x, max_y)
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day8.txt")

frequencies = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce(%{}, fn {line, y}, acc ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce(acc, fn {s, x}, acc ->
    case {s, acc[s]} do
      {".", _} -> acc
      {_, nil} -> acc |> Map.put(s, [{x,y}])
      {_, _} -> %{acc | s => [{x,y} | acc[s]]}
    end
  end)
end)

max_y = (input |> String.split("\n") |> Enum.count()) - 1
max_x = (input |> String.split("\n") |> Enum.at(0) |> String.length) - 1

antinodes = frequencies
|> Map.values()
|> Enum.flat_map(fn points ->
  points
  |> Enum.flat_map(fn {point_x, point_y} ->
    points
    |> Enum.filter(fn p -> p != {point_x,point_y} end)
    |> Enum.flat_map(fn {point2_x, point2_y} ->
      diff_x = point_x - point2_x
      diff_y = point_y - point2_y

      n_x = point_x + diff_x
      n_y = point_y + diff_y

      Funcs.test_operators({n_x, n_y}, {diff_x, diff_y}, [{point_x,point_y}], max_x, max_y)
    end)
  end)
end)
|> Enum.into(%MapSet{})
# |> IO.inspect()

antinodes
|> Enum.count()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
