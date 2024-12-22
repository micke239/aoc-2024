Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"lowest", Map.new()})
:ets.insert(:my_secret_test, {"lowest_score", 10000000000000000})

defmodule Funcs do
  def find_path(p, _, ending, path, _, score) when p == ending do
    IO.puts("found #{score}")
    :ets.insert(:my_secret_test, {"lowest_score", score})
    {path, score}
  end

  def find_path(p, walls, ending, path, dir, score) do
    n_path = MapSet.put(path, p)

    alts = neighbours()
    |> Enum.map(fn n -> {move(p, n), n} end)
    |> Enum.filter(fn {n,_} -> !MapSet.member?(walls, n) end)
    |> Enum.filter(fn {n,_} -> !MapSet.member?(path, n) end)
    |> Enum.map(fn {n, n_dir} ->
      n_score = if (n_dir == dir) do
        score + 1
      else
        score + 1001
      end

      {n, n_dir, n_score}
    end)
    |> Enum.sort(fn {_, _, n_score1}, {_, _, n_score2} ->
      n_score1 < n_score2
    end)
    |> Enum.map(fn {n, n_dir, n_score} ->
      [{_, lows}] = :ets.lookup(:my_secret_test, "lowest")
      [{_, lowest_score}] = :ets.lookup(:my_secret_test, "lowest_score")
      prev_low = lows[n] #spelar roll varifrån man kommer....

      if (n_score > prev_low || n_score > lowest_score) do
        {path, 10000000}
      else
        :ets.insert(:my_secret_test, {"lowest", Map.put(lows, n, n_score)})
        find_path(n, walls, ending, n_path, n_dir, n_score)
      end
    end)

    if (Enum.any?(alts)) do
      alts |> Enum.min(fn {_, s1}, {_, s2} -> s1 < s2 end)
    else
      {n_path, 1000000}
    end
  end

  def find_path2([], _walls, _ending, _lowest_paths, lowest_score, lowest_score_paths) do
    {lowest_score, lowest_score_paths}
  end

  def find_path2([{p, _dir, path, score} | rest], walls, ending, lowest_paths, lowest_score, lowest_score_paths) when p == ending do
    #IO.puts("found #{score}")
    lowest_score_paths = if score == lowest_score do
      [path | lowest_score_paths]
    else
      [path]
    end
    find_path2(rest, walls, ending, lowest_paths, score, lowest_score_paths)
  end

  def find_path2([{p, dir, path, score} | rest], walls, {e_x, e_y}, lowest_paths, lowest_score, lowest_score_paths) do
    if score > lowest_paths[{p,dir}] || score > lowest_score do
       find_path2(rest, walls, {e_x, e_y}, lowest_paths, lowest_score, lowest_score_paths)
    else
      n_path = [{p, dir} | path]
      alts = neighbours()
      |> Enum.filter(fn n -> case dir do
        :north -> n != :south
        :south -> n != :north
        :east -> n != :west
        :west -> n != :east
        end
      end)
      |> Enum.map(fn n -> {move(p, n), n} end)
      |> Enum.filter(fn {n,_} -> !MapSet.member?(walls, n) end)
      |> Enum.map(fn {n, n_dir} ->
        n_score = if (n_dir == dir) do
          score + 1
        else
          score + 1001
        end

        {n, n_dir, n_path, n_score}
      end)

      sort_by = fn {{x1,y1},_dir,_path,_score} ->
        abs(e_x - x1) + abs(e_y - y1)
      end

      alts = alts |> Enum.sort_by(sort_by, :desc)

      n_tests = insert_sorted(rest, alts, sort_by)

      find_path2(n_tests, walls, {e_x, e_y}, Map.put(lowest_paths, {p,dir}, score), lowest_score, lowest_score_paths)
    end
  end

  def insert_sorted([into_head | into_rest], [insert_head | insert_rest], sort_by) do
    if (sort_by.(into_head) > sort_by.(insert_head)) do
      [into_head | insert_sorted(into_rest, [insert_head | insert_rest], sort_by)]
    else
      [insert_head | [into_head | insert_sorted(into_rest, insert_rest, sort_by)]]
    end
  end

  def insert_sorted([], [], _comparer) do
    []
  end

  def insert_sorted([], [insert_head | insert_rest], _comparer) do
    [insert_head | insert_rest]
  end

  def insert_sorted([into_head | into_rest], [], _comparer) do
    [into_head | into_rest]
  end

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
end

start_t = System.os_time(:millisecond)

input = File.read!("input/day16.txt")

{_max_x, _max_y, walls, start, ending} = input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({0,0, MapSet.new(), nil, nil}, fn {line, y}, {max_x, max_y, walls, start, ending} ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce({max_x, max_y, walls, start, ending}, fn {s, x}, {_max_x, _max_y, walls, start, ending} ->
    case s do
      "#" -> {x, y, MapSet.put(walls, {x,y}), start, ending}
      "S" -> {x, y, walls, {x,y}, ending}
      "E" -> {x, y, walls, start, {x,y}}
      _ -> {x, y, walls, start, ending}
    end
  end)
end)

##PART 1
start2_t = System.os_time(:millisecond)
{score, paths} = Funcs.find_path2([{start, :east, [], 0}], walls, ending, Map.new(), 1000000, [])
# {_, score2} = Funcs.find_path(start, walls, ending, MapSet.new(), :east, 0)
IO.puts(System.os_time(:millisecond) - start2_t)

visited = paths
|> List.flatten()
|> Enum.map(&(elem(&1, 0)))
|> Enum.into(MapSet.new())

# 0..max_y |> Enum.map(fn y ->
#   0..max_x |> Enum.map(fn x ->
#     cond do
#       MapSet.member?(walls, {x,y}) -> IO.write("#")
#       MapSet.member?(visited, {x,y}) -> IO.write("O")
#       true -> IO.write(".")
#     end
#   end)
#   IO.write("\n")
# end)
# IO.write("\n")

IO.inspect(score)

visited
|> Enum.count()
|> Kernel.+(1)
|> IO.inspect()

# IO.inspect(score2)
# IO.inspect(path |> Enum.count())

IO.puts(System.os_time(:millisecond) - start_t)
