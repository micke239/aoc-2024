Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def find_strings(char_map, step_fn, end_fn, curr, [curr_acc | done], max_x, max_y, orig) do
    n_acc = [char_map[curr] | curr_acc]
    {n_x,n_y} = step_fn.(curr)
    if (n_x > max_x || n_y > max_y || n_x < 0 || n_y < 0) do
      {n_x,n_y} = end_fn.(orig)
      if (n_x > max_x || n_y > max_y || n_x < 0 || n_y < 0) do
        [n_acc | done]
      else
        Funcs.find_strings(char_map, step_fn, end_fn, {n_x,n_y}, [[] | [n_acc | done]], max_x, max_y, {n_x,n_y})
      end
    else
      Funcs.find_strings(char_map, step_fn, end_fn, {n_x,n_y}, [n_acc | done], max_x, max_y, orig)
    end
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day4.txt")

char_map = input
|> String.split("\n")
|> Enum.with_index()
|> Enum.flat_map(fn {s, y} ->
  s |> String.graphemes |> Enum.with_index() |> Enum.map(fn {c, x} -> {{x,y}, c} end)
end)
|> Enum.into(%{})

max_x = char_map |> Enum.map(fn {{x,_},_} -> x end) |> Enum.max() |> IO.inspect()
max_y = char_map |> Enum.map(fn {{_,y},_} -> y end) |> Enum.max() |> IO.inspect()

[Funcs.find_strings(char_map, fn {x,y} -> {x+1,y} end, fn {x,y} -> {x,y+1} end, {0,0}, [[]], max_x, max_y, {0,0}),
  Funcs.find_strings(char_map, fn {x,y} -> {x+1,y+1} end, fn {x,y} -> {x+1,y} end, {0,0}, [[]], max_x, max_y, {0,0}),
  Funcs.find_strings(char_map, fn {x,y} -> {x+1,y+1} end, fn {x,y} -> {x,y+1} end, {0,1}, [[]], max_x, max_y, {0,1}),
  Funcs.find_strings(char_map, fn {x,y} -> {x-1,y+1} end, fn {x,y} -> {x-1,y} end, {max_x,0}, [[]], max_x, max_y, {max_x,0}),
  Funcs.find_strings(char_map, fn {x,y} -> {x-1,y+1} end, fn {x,y} -> {x,y+1} end, {max_x,1}, [[]], max_x, max_y, {max_x,1}),
  Funcs.find_strings(char_map, fn {x,y} -> {x,y+1} end, fn {x,y} -> {x+1,y} end, {0,0}, [[]], max_x, max_y, {0,0})]
  |> Enum.flat_map(fn x -> x end)
  |> Enum.flat_map(fn x -> [x |> Enum.reverse(), x ] end)
  |> Enum.map(fn x -> Enum.join(x) end)
  |> Enum.map(fn x -> Regex.scan(~r/XMAS/, x) |> Enum.count() end)
  |> Enum.sum()
  |> IO.inspect()

char_map
  |> Enum.count(fn {{x,y},s} ->
    if (x+2 > max_x || y+2 > max_y) do
      false
    else
      str1 = "#{char_map[{x,y}]}#{char_map[{x+1,y+1}]}#{char_map[{x+2,y+2}]}"
      str2 = "#{char_map[{x+2,y}]}#{char_map[{x+1,y+1}]}#{char_map[{x,y+2}]}"

      (str1 == "MAS" || str1 == "SAM") && (str2 == "MAS" || str2 == "SAM")
    end
  end)
  |> IO.inspect()




IO.puts(System.os_time(:millisecond) - start)
