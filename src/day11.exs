Code.require_file("utilities.ex", "./src")

defmodule Funcs do

end

start = System.os_time(:millisecond)

input = File.read!("input/day11.txt")

stones = input
|> String.split("\s")
|> Enum.map(&(String.to_integer(&1)))
|> Enum.reduce(%{}, fn x, acc ->
  if (Map.has_key?(acc, x)) do
    Map.put(acc, x, acc[x] + 1)
  else
    Map.put(acc, x, 1)
  end
end)

1..75
|> Enum.reduce(stones, fn i, stones ->
  if (i == 26) do
    #part 1
    stones
    |> Enum.map(fn {_,x} -> x end)
    |> Enum.sum()
    |> IO.inspect()
  end
  stones
  |> Enum.reduce(%{}, fn {st, count}, acc ->
    s = to_string(st)
    l = String.length(s)

    new_vals = cond do
      st == 0 -> [1]
      rem(l,2) == 0 ->
        {x,y} = s |> String.split_at(div(String.length(s),2))
        [String.to_integer(x),String.to_integer(y)]
      true -> [st * 2024]
    end

    new_vals
      |> Enum.reduce(acc, fn x, acc ->
        if (Map.has_key?(acc, x)) do
          Map.put(acc, x, acc[x] + count)
        else
          Map.put(acc, x, count)
        end
      end)
  end)
end)
|> Enum.map(fn {_,x} -> x end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
