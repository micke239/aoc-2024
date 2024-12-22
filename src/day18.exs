# Code.require_file("utilities.ex", "./src")

defmodule Funcs do

  def find_path2([], _walls, _ending, _lowest_paths, _lowest_score, _lowest_score_paths, _max_x, _max_y,_sort_dir) do
    {nil, nil}
  end

  def find_path2([{p, path, score} | _rest], _walls, ending, _lowest_paths, _lowest_score, _lowest_score_paths, _max_x, _max_y,_sort_dir) when p == ending do
    {score, path}
  end

  def find_path2([{p, path, score} | rest], walls, {e_x, e_y}, lowest_paths, lowest_score, lowest_score_paths, max_x, max_y, sort_dir) do
    if score >= lowest_paths[p] do
      find_path2(rest, walls, {e_x, e_y}, lowest_paths, lowest_score, lowest_score_paths,max_x,max_y,sort_dir)
    else
      n_path = MapSet.put(path, p)
      alts = neighbours()
      |> Enum.map(fn n -> move(p, n) end)
      |> Enum.filter(fn {x,y} -> x in 0..max_x && y in 0..max_y end)
      |> Enum.filter(fn n -> !MapSet.member?(walls, n) end)
      |> Enum.filter(fn n -> !MapSet.member?(n_path, n) end)
      |> Enum.map(fn n ->
        {n, n_path, score+1}
      end)

      sort_by = fn {{x1,y1},_path,_score} ->
        abs(e_x - x1) + abs(e_y - y1)
      end

      alts = alts |> Enum.sort_by(sort_by, sort_dir)

      n_tests = insert_sorted(rest, alts, sort_by, sort_dir)

      find_path2(n_tests, walls, {e_x, e_y}, Map.put(lowest_paths, p, score), lowest_score, lowest_score_paths,max_x,max_y,sort_dir)
    end
  end

  def insert_sorted([into_head | into_rest], [insert_head | insert_rest], sort_by, sort_dir) do
    sorted = if sort_dir == :desc do
      sort_by.(into_head) > sort_by.(insert_head)
    else
      sort_by.(into_head) < sort_by.(insert_head)
    end

    if (sorted) do
      [into_head | insert_sorted(into_rest, [insert_head | insert_rest], sort_by, sort_dir)]
    else
      [insert_head | [into_head | insert_sorted(into_rest, insert_rest, sort_by, sort_dir)]]
    end
  end

  def insert_sorted([], [], _comparer,_sort_dir) do
    []
  end

  def insert_sorted([], [insert_head | insert_rest], _comparer, _sort_dir) do
    [insert_head | insert_rest]
  end

  def insert_sorted([into_head | into_rest], [], _comparer, _sort_dir) do
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

input = File.read!("input/day18.txt")

unsafe = input
|> String.split("\n")
|> Enum.map(fn line ->
  [x,y] = line |> String.split(",")
  {String.to_integer(x),String.to_integer(y)}
end)

max_x = 70
max_y = 70

{score, _} = Funcs.find_path2([{{0,0}, MapSet.new(), 0}], unsafe |> Enum.take(1024) |> Enum.into(MapSet.new()), {max_x,max_y}, %{}, 1000000, [], max_x, max_y, :desc)

IO.puts(score)

{coord_x, coord_y} = Stream.iterate(0, &(&1+1))
|> Enum.reduce_while(1025, fn _, acc ->
  walls = unsafe |> Enum.take(acc) |> Enum.into(MapSet.new())
  {score, path} = Funcs.find_path2([{{0,0}, MapSet.new(), 0}], walls, {max_x,max_y}, %{}, 1000000, [], max_x, max_y, :asc)
  if (score != nil) do
    {:cont, acc + 1 + (unsafe |> Enum.drop(acc) |> Enum.find_index(&(MapSet.member?(path, &1))))}
  else
    {:halt, Enum.at(unsafe, acc-1)}
  end
end)

IO.puts("#{coord_x},#{coord_y}")

IO.puts(System.os_time(:millisecond) - start_t)
