#Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"cache", Map.new()})

defmodule Funcs do


end

start_t = System.os_time(:millisecond)

input = File.read!("input/day25.txt")

all = input
|> String.split("\n\n")
|> Enum.map(fn map ->
  map
  |> String.split("\n")
  |> Enum.with_index()
  |> Enum.reduce({false, %{0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0}}, fn {l,y}, {is_lock, acc} ->

    cond do
      y == 0 -> {l == "#####", acc}
      y == 6 -> {is_lock, acc}
      true ->
        acc = l
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c,x}, acc ->
          case c do
            "#" -> Map.put(acc, x, if Map.has_key?(acc, x) do acc[x] + 1 else 1 end)
            _ -> acc
          end
        end)

        {is_lock, acc}
    end
  end)
end)
|> IO.inspect()

locks = all |> Enum.filter(fn {is_lock, _} -> is_lock end)
keys = all |> Enum.filter(fn {is_lock, _} -> !is_lock end)

locks
|> Enum.map(fn {_,l} ->
  keys |> Enum.count(fn {_,k} ->
    l[0] + k[0] <= 5 &&
    l[1] + k[1] <= 5 &&
    l[2] + k[2] <= 5 &&
    l[3] + k[3] <= 5 &&
    l[4] + k[4] <= 5
  end)
end)
|> Enum.sum()
|> IO.inspect()


IO.puts(System.os_time(:millisecond) - start_t)
