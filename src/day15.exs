Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])

defmodule Funcs do
  def try_move(pos, stones, walls, move, is_stone) do
    n_pos = move.(pos)

    {result, n_stones, _} = cond do
      MapSet.member?(walls, n_pos) -> {:stuck, stones, pos}
      MapSet.member?(stones, n_pos) -> try_move(n_pos, stones, walls, move, true)
      true -> {:success, stones, pos}
    end

    case result do
      :stuck -> {:stuck, stones, pos}
      :success -> if is_stone do
        {:success,  MapSet.put(n_stones, n_pos) |> MapSet.delete(pos), n_pos}
      else
        {:success, n_stones, n_pos}
      end
    end
  end

  def try_move_box(pos, stones, walls, move, is_box) do
    n_pos = move.(pos)

    surface = if is_box do
      [n_pos, {elem(n_pos,0)+1,elem(n_pos,1)}]
    else
      [n_pos]
    end

    colliding_walls = surface
    |> Enum.filter(fn {x,y} ->
      MapSet.member?(walls, {x,y})
    end)

    if (Enum.any?(colliding_walls)) do
      {:stuck, stones, pos}
    else
      n_stones = if (is_box) do
        MapSet.delete(stones, pos)
      else
        stones
      end

      colliding_boxes = surface
        |> Enum.map(fn {x,y} ->
          cond do
            MapSet.member?(n_stones, {x,y}) -> {x,y}
            MapSet.member?(n_stones, {x-1,y}) -> {x-1,y}
            true -> nil
          end
        end)
        |> Enum.filter(&(&1 != nil))
        |> Enum.uniq()

      {result, n_stones} = colliding_boxes
      |> Enum.reduce({:success, n_stones}, fn stone_pos, {result, n_stones} ->
          if (result == :stuck) do
            {:stuck, n_stones}
          else
            {result, n_stones, _} = try_move_box(stone_pos, n_stones, walls, move, true)
            {result, n_stones}
          end
      end)

      case result do
        :stuck -> {:stuck, stones, pos}
        :success -> if is_box do
          {:success, n_stones |> MapSet.put(n_pos), n_pos}
        else
          {:success, n_stones, n_pos}
        end
      end
    end
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day15.txt")

[map_input, instruction_input] = input |> String.split("\n\n")

{_max_x, _max_y, walls, stones, pos} = map_input
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({0,0, MapSet.new(), MapSet.new(), nil}, fn {line, y}, {max_x, max_y, walls, stones, pos} ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce({max_x, max_y, walls, stones, pos}, fn {s, x}, {_max_x, _max_y, walls, stones, pos} ->
    case s do
      "#" -> {x, y, MapSet.put(walls, {x,y}), stones, pos}
      "O" -> {x, y, walls, MapSet.put(stones, {x,y}), pos}
      "@" -> {x, y, walls, stones, {x,y}}
      _ -> {x, y, walls, stones, pos}
    end
  end)
end)

##PART 1

{stones, pos} = instruction_input
|> String.graphemes()
|> Enum.filter(&(&1 != "\n"))
|> Enum.reduce({stones, pos}, fn instr, {stones, pos} ->

  move = case instr do
    ">" -> fn {x,y} -> {x+1,y} end
    "v" -> fn {x,y} -> {x,y+1} end
    "<" -> fn {x,y} -> {x-1,y} end
    "^" -> fn {x,y} -> {x,y-1} end
  end

  {res, n_stones, n_pos} = Funcs.try_move(pos, stones, walls, move, false)

  if (res == :success) do
    {n_stones, n_pos}
  else
    {stones, pos}
  end
end)

stones
|> Enum.map(fn {x,y} ->
100*y + x
end)
|> Enum.sum()
|> IO.inspect()

## part_2

{_max_x, _max_y, walls, stones, _pos} = map_input
|> String.replace("#", "##")
|> String.replace("O", "[]")
|> String.replace(".", "..")
|> String.replace("@", "@.")
|> String.split("\n")
|> Enum.with_index
|> Enum.reduce({0,0, MapSet.new(), MapSet.new(), nil}, fn {line, y}, {max_x, max_y, walls, stones, pos} ->
 line
 |> String.graphemes()
 |> Enum.with_index()
 |> Enum.reduce({max_x, max_y, walls, stones, pos}, fn {s, x}, {_max_x, _max_y, walls, stones, pos} ->
    case s do
      "#" -> {x, y, MapSet.put(walls, {x,y}), stones, pos}
      "[" -> {x, y, walls, MapSet.put(stones, {x,y}), pos}
      "@" -> {x, y, walls, stones, {x,y}}
      _ -> {x, y, walls, stones, pos}
    end
  end)
end)

{stones, _pos} = instruction_input
|> String.graphemes()
|> Enum.filter(&(&1 != "\n"))
|> Enum.reduce({stones, pos}, fn instr, {stones, pos} ->
  move = case instr do
    ">" -> fn {x,y} -> {x+1,y} end
    "v" -> fn {x,y} -> {x,y+1} end
    "<" -> fn {x,y} -> {x-1,y} end
    "^" -> fn {x,y} -> {x,y-1} end
  end

  {res, n_stones, n_pos} = Funcs.try_move_box(pos, stones, walls, move, false)

  if (res == :success) do
    {n_stones, n_pos}
  else
    {stones, pos}
  end
end)

stones
|> Enum.map(fn {x,y} ->
  100*y + x
end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
