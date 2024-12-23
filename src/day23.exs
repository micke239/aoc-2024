#Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"cache", Map.new()})

defmodule Funcs do
  def follow(curr, path, depth, _connections, max_depth) when depth == (max_depth-1) do
    [MapSet.put(path, curr)]
  end
  def follow(curr, path, depth, connections, _max_depth) do
    n_curr = MapSet.put(path, curr)
    connections[curr]
    |> Enum.filter(fn x ->
      not_friendly = MapSet.difference(path, connections[x])
      MapSet.size(not_friendly) == 0
    end)
    |> Enum.flat_map(fn x -> Funcs.follow(x,n_curr, depth+1, connections, 3) end)
    |> Enum.filter(fn r -> r != :not_found end)
    |> Enum.uniq()
  end

  def follow2(curr, path, connections) do
    n_path = MapSet.put(path, curr)
    cons = connections[curr]
    |> Enum.filter(fn x -> !MapSet.member?(path,x) end)
    |> Enum.filter(fn x ->
      MapSet.size(MapSet.difference(path, connections[x])) == 0
    end)

    if (!Enum.any?(cons)) do
      n_path
    else
      n_test = cons |> Enum.at(0)
      Funcs.follow2(n_test,n_path, connections)
    end

  end


end

start_t = System.os_time(:millisecond)



connections =
  File.read!("input/day23.txt")
  |> String.split("\n")
  |> Enum.map(&(String.split(&1,"-")))
  |> Enum.flat_map(fn [x,y] -> [{x,y},{y,x}] end)
  |> Enum.group_by(fn {x,_} -> x end, fn {_,y} -> y end)
  |> Enum.map(fn {x,y} -> {x, y |> Enum.into(MapSet.new()) } end)
  |> Enum.into(Map.new())


threes = connections
|> Map.keys()
|> Enum.filter(fn x -> String.starts_with?(x, "t") end)
|> Enum.flat_map(fn c ->
  connections[c]
  |> Enum.flat_map(fn x -> Funcs.follow(x, MapSet.new([c]), 1, connections, 3) end)
end)
|> Enum.uniq()

threes
|> Enum.count()
|> IO.inspect()

#part2

connections
|> Map.keys()
|> Enum.reduce(MapSet.new(), fn c, acc ->
  test = connections[c] |> Enum.at(0)

  path = Funcs.follow2(test, MapSet.new([c]), connections)

  MapSet.put(acc, path)
end)
|> Enum.max_by(fn x -> Enum.count(x) end)
|> Enum.sort()
|> Enum.join(",")
|> IO.puts()



IO.puts(System.os_time(:millisecond) - start_t)
