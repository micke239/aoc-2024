Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def count_turns({x,y}, dir, perimeter, count, visited, is_new) do
    if (MapSet.member?(visited, {{x,y}, dir})) do
      {count, visited, is_new}
    else

      {n_p,n_dir,_} = case dir do
        nil -> cond do
          MapSet.member?(perimeter, {x+0.5,y}) -> {{x+0.5,y}, :right,count+1}
          MapSet.member?(perimeter, {x-0.5,y}) -> {{x-0.5,y}, :left,count+1}
          MapSet.member?(perimeter, {x,y-0.5}) -> {{x,y-0.5}, :up,count+1}
          MapSet.member?(perimeter, {x,y+0.5}) -> {{x,y+0.5}, :down,count+1}
        end
        :up -> cond do
          MapSet.member?(perimeter, {x+0.5,y}) -> {{x+0.5,y}, :right,count+1}
          MapSet.member?(perimeter, {x-0.5,y}) -> {{x-0.5,y}, :left,count+1}
          true -> {{x,y-0.5},:up,count}
        end
        :right -> cond do
          MapSet.member?(perimeter, {x,y+0.5}) -> {{x,y+0.5}, :down,count+1}
          MapSet.member?(perimeter, {x,y-0.5}) -> {{x,y-0.5}, :up,count+1}
          true -> {{x+0.5,y},:right,count}
        end
        :down -> cond do
          MapSet.member?(perimeter, {x-0.5,y}) -> {{x-0.5,y},:left,count+1}
          MapSet.member?(perimeter, {x+0.5,y}) -> {{x+0.5,y},:right,count+1}
          true -> {{x,y+0.5},:down,count}
        end
        :left -> cond do
          MapSet.member?(perimeter, {x,y-0.5}) -> {{x,y-0.5},:up,count+1}
          MapSet.member?(perimeter, {x,y+0.5}) -> {{x,y+0.5},:down,count+1}
          true -> {{x-0.5,y},:left,count}
        end
      end

      if MapSet.member?(perimeter, n_p) do
        visited = MapSet.put(visited, {{x,y}, dir})
        count = if (is_new && n_dir == dir) do
          count + 1
        else
          count
        end
        count_turns(n_p, n_dir, perimeter, count, visited, n_dir != dir && dir != nil)
      else
        {_,n_dir,_} = case dir do
          :up -> cond do
            MapSet.member?(perimeter, {x+0.5,y}) -> {{x+0.5,y}, :right,count+1}
            MapSet.member?(perimeter, {x-0.5,y}) -> {{x-0.5,y}, :left,count+1}
            true -> {{x,y},:down,count}
          end
          :right -> cond do
            MapSet.member?(perimeter, {x,y-0.5}) -> {{x,y-0.5}, :up,count+1}
            MapSet.member?(perimeter, {x,y+0.5}) -> {{x,y+0.5}, :down,count+1}
            true -> {{x,y},:left,count}
          end
          :down -> cond do
            MapSet.member?(perimeter, {x+0.5,y}) -> {{x+0.5,y},:right,count+1}
            MapSet.member?(perimeter, {x-0.5,y}) -> {{x-0.5,y},:left,count+1}
            true -> {{x,y},:up,count}
          end
          :left -> cond do
            MapSet.member?(perimeter, {x,y-0.5}) -> {{x,y-0.5},:up,count+1}
            MapSet.member?(perimeter, {x,y+0.5}) -> {{x,y+0.5},:down,count+1}
            true -> {{x,y},:right,count}
          end
        end

        count_turns({x,y}, n_dir, perimeter, count, visited, true)
      end
    end
  end
  def scan(p, next, perimeter) do
    if MapSet.member?(perimeter, p) do
      [p | scan(next.(p), next, perimeter)]
    else
      []
    end
  end
  def neighbours({x,y}) do
    [{x+1,y},{x-1,y},{x,y+1},{x,y-1}]
  end
  def neighbours2({x,y}) do
    [{x+1,y},{x-1,y},{x,y+1},{x,y-1},{x-1,y-1},{x-1,y+1},{x+1,y-1},{x+1,y+1}]
  end
  def neighbours2() do
    [:east,:west,:south,:north,:northwest,:northeast,:southwest,:southeast]
  end
  def move({x,y}, dir, by) when Kernel.is_float(by) do
    case dir do
      :east -> {x+by,y+0.0}
      :west -> {x-by,y+0.0}
      :south -> {x+0.0,y+by}
      :north -> {x+0.0,y-by}
      :northwest -> {x-by,y-by}
      :northeast -> {x+by,y-by}
      :southwest -> {x-by,y+by}
      :southeast -> {x+by,y+by}
    end
  end
  def move({x,y}, dir, by) do
    case dir do
      :east -> {x+by,y}
      :west -> {x-by,y}
      :south -> {x,y+by}
      :north -> {x,y-by}
      :northwest -> {x-by,y-by}
      :northeast -> {x+by,y-by}
      :southwest -> {x-by,y+by}
      :southeast -> {x+by,y+by}
    end
  end
  def find_buddies({x,y}, map, value, acc) do
    acc = MapSet.put(acc, {x,y})

    neighbours({x,y})
    |> Enum.filter(&(map[&1] == value))
    |> Enum.filter(&(!MapSet.member?(acc, &1)))
    |> Enum.reduce(acc, fn p, acc ->
      MapSet.union(acc, find_buddies(p, map, value, acc))
    end)
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day12.txt")

map = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce(%{}, fn {line, y}, acc ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce(acc, fn {s, x}, acc -> Map.put(acc, {x,y}, s) end)
end)
# |> IO.inspect()


{regions, _} = map
|> Enum.reduce({[], %MapSet{}}, fn {{x,y}, value}, {acc, handled} ->
  if MapSet.member?(handled, {x,y}) do
    {acc,handled}
  else
    buddies = Funcs.find_buddies({x,y}, map, value, %MapSet{})
    {[buddies | acc], MapSet.union(handled, buddies)}
  end
end)
# |> IO.inspect()

regions
|> Enum.map(fn region ->
  perimeter = region
    |> Enum.map(fn p ->
      Funcs.neighbours(p)
      |> Enum.count(&(!MapSet.member?(region, &1)))
    end)
    |> Enum.sum()

    perimeter * (region |> Enum.count())
end)
|> Enum.sum()
|> IO.inspect()

regions
|> Enum.map(fn region ->
  perimeter = region
    |> Enum.flat_map(fn p ->
      Funcs.neighbours2()
      |> Enum.filter(fn x ->
        case x do
          :northeast -> !MapSet.member?(region, Funcs.move(p,:north,1)) || !MapSet.member?(region, Funcs.move(p,:east,1))
          :northwest -> !MapSet.member?(region, Funcs.move(p,:north,1)) || !MapSet.member?(region, Funcs.move(p,:west,1))
          :southeast -> !MapSet.member?(region, Funcs.move(p,:south,1)) || !MapSet.member?(region, Funcs.move(p,:east,1))
          :southwest -> !MapSet.member?(region, Funcs.move(p,:south,1)) || !MapSet.member?(region, Funcs.move(p,:west,1))
          _ -> !MapSet.member?(region, Funcs.move(p,x,1))
        end
      end)
      |> Enum.map(&(Funcs.move(p,&1,0.5)))
    end)
    |> Enum.into(MapSet.new())

  {sides, _} = perimeter
      |> Enum.sort(fn {x1,y1}, {x2,y2} -> cond do
        x1 < x2 -> true
        x2 < x1 -> false
        y1 < y2 -> true
        y2 < y1 -> false
        true -> true
      end
      end)
      |> Enum.reduce({0, MapSet.new()}, fn p, {count, ignore} ->
    if MapSet.member?(ignore, p) do
      {count, ignore}
    else
      {turns, visited, is_new} = Funcs.count_turns(p, nil, perimeter, 0, MapSet.new(), false)
      extra_c = if is_new do 1 else 0 end
      visited_points = visited |> Enum.map(&(elem(&1, 0))) |> Enum.into(MapSet.new())
      {count + turns + extra_c, MapSet.union(ignore, visited_points)}
    end
  end)

  (sides) * (region |> Enum.count())
end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
