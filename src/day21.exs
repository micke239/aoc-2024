#Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"cache", Map.new()})

defmodule Funcs do
  def neighbours() do
    [:right,:left,:down,:up]
  end

  def move({x,y}, dir) do
    case dir do
      :right -> {x+1,y}
      :left -> {x-1,y}
      :down -> {x,y+1}
      :up -> {x,y-1}
    end
  end

  def find_path({path, curr}, to, _pad) when curr == to do
    [path]
  end

  def find_path({path, curr}, to, pad) do
    neighbours()
    |> Enum.map(fn n -> {n, move(curr, n)} end)
    |> Enum.filter(fn {_dir, n} -> Map.has_key?(pad, n) end)
    |> Enum.filter(fn {_dir, n} -> !Enum.any?(path, &(elem(&1,1) == n)) end)
    |> Enum.flat_map(fn {dir,n} ->
      find_path({[{dir,n} | path], n}, to, pad)
    end)
  end

  def map_code(c, code, curr, max, small_pad, small_map, small_pad_lookup) do
    [{_,cache}] = :ets.lookup(:my_secret_test, "cache")
    if (Map.has_key?(cache, {code, curr})) do
      cache[{code,curr}]
    else
      res = code |> Enum.reduce({{2,0}, 0}, fn {c2,_}, {from2, path2} ->
        to2 = small_pad_lookup[c2]

        if (from2 == to2) do
          {to2, path2 + 1}
        else
          potential_paths2 = small_map[{from2, to2}]
            |> Enum.map(fn p -> p ++ [{:A, {2,3}}] end)

          e_path2 = potential_paths2
          |> Enum.map(fn code3 ->
            if curr == max do
              code3 |> Enum.reduce({{2,0}, 0}, fn {c3,_}, {from3, path3} ->
                to3 = small_pad_lookup[c3]
                if (from3 == to3) do
                  {to3, path3 + 1}
                else
                  {to3,path3 + Enum.count((small_map[{from3, to3}] |> Enum.at(0))) + 1}
                end
              end)
            else
              Funcs.map_code(c, code3, curr+1, max, small_pad, small_map,small_pad_lookup)
            end
          end)
          |> Enum.map(&(elem(&1,1)))
          |> Enum.min()

          {to2, path2 + e_path2}
        end
      end)

      [{_,cache}] = :ets.lookup(:my_secret_test, "cache")
      :ets.insert(:my_secret_test, {"cache", Map.put(cache, {code,curr}, res)})

      res
    end
  end
end

start_t = System.os_time(:millisecond)

large_pad = %{
  {0,0} => 7,
  {1,0} => 8,
  {2,0} => 9,
  {0,1} => 4,
  {1,1} => 5,
  {2,1} => 6,
  {0,2} => 1,
  {1,2} => 2,
  {2,2} => 3,
  {1,3} => 0,
  {2,3} => :A,
}

small_pad = %{
  {1,0} => :up,
  {2,0} => :A,
  {0,1} => :left,
  {1,1} => :down,
  {2,1} => :right,
}

small_pad_lookup =
  small_pad
  |> Enum.map(fn {x,y} -> {y,x} end)
  |> Enum.into(%{})

input = File.read!("input/day21.txt")



codes = input
|> String.split("\n")
|> Enum.map(fn l ->
  l
  |> String.graphemes()
  |> Enum.map(fn c ->
    case c do
      "A" -> :A
      _ -> String.to_integer(c)
    end
  end)
end)
|> IO.inspect()


large_combos = for x <- large_pad, y <- large_pad, x != y, do: {x, y}
small_combos = for x <- small_pad, y <- small_pad, x != y, do: {x, y}


small_map = small_combos
|> Enum.map(fn {{from_p, _from_v},{to_p, _to_v}} ->
  paths = Funcs.find_path({[], from_p}, to_p, small_pad)

  {_, min_paths} = paths
  |> Enum.group_by(fn p -> Enum.count(p) end)
  |> Enum.min_by(&(elem(&1,0)))

  {{from_p, to_p}, min_paths |> Enum.map(&(Enum.reverse(&1)))}
end)
|> Enum.into(%{})

large_map = large_combos
|> Enum.map(fn {{from_p, _from_v},{to_p, _to_v}} ->
  paths = Funcs.find_path({[], from_p}, to_p, large_pad)
  {_,min_paths} = paths
  |> Enum.group_by(fn p -> Enum.count(p) end)
  |> Enum.min_by(&(elem(&1,0)))

  {{from_p, to_p}, min_paths |> Enum.map(&(Enum.reverse(&1)))}
end)
|> Enum.into(%{})

#part 1

codes
|> Enum.map(fn code ->
  {_,p} = code
  |> Enum.reduce({{2,3}, 0}, fn c, {from, count} ->
    {to,_} = large_pad |> Enum.find(fn {_p,v} -> v == c end)

    if (from == to) do
      {to, count + 1}
    else
      potential_paths = large_map[{from, to}]
      |> Enum.map(fn p -> p ++ [{:A, {2,3}}] end)

      e_path = potential_paths
      |> Enum.map(fn code2 ->
        Funcs.map_code(c, code2,1,1,small_pad,small_map,small_pad_lookup)
      end)
      |> Enum.map(&(elem(&1,1)))
      |> Enum.min()

      {to, count + e_path}
    end
  end)

  String.to_integer(String.slice(Enum.join(code), 0..-2//1)) * p
end)
|> Enum.sum()
|> IO.inspect()

:ets.insert(:my_secret_test, {"cache", Map.new()})

#part 2

codes
|> Enum.map(fn code ->
  {_,p} = code
  |> Enum.reduce({{2,3}, 0}, fn c, {from, count} ->
    {to,_} = large_pad |> Enum.find(fn {_p,v} -> v == c end)

    if (from == to) do
      {to, count + 1}
    else
      potential_paths = large_map[{from, to}]
      |> Enum.map(fn p -> p ++ [{:A, {2,3}}] end)

      e_path = potential_paths
      |> Enum.map(fn code2 ->
        Funcs.map_code(c, code2,1,24,small_pad,small_map,small_pad_lookup)
      end)
      |> Enum.map(&(elem(&1,1)))
      |> Enum.min()

      {to, count + e_path}
    end
  end)

  String.to_integer(String.slice(Enum.join(code), 0..-2//1)) * p
end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start_t)
