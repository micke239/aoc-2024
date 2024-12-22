Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])

defmodule Funcs do
  def find(a_x_move, b_x_move, res_x, a_y_move, b_y_move, res_y, curr_x, curr_y, state, cache_key, cache_min_key) do

  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day14.txt")

security_bots = input
|> String.split("\n")
|> Enum.map(fn line ->
  IO.inspect(line)
  IO.inspect(Regex.run(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line))
  [_,p_x, p_y, v_x, v_y] = Regex.run(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line)

  {
    {String.to_integer(p_x),String.to_integer(p_y)},
    {String.to_integer(v_x),String.to_integer(v_y)},
  }
end)
|> IO.inspect()

 max_x=101-1
 max_y=103-1

#max_x=11-1
#max_y=7-1

[{quad1r_x, quad1r_y}, {quad2r_x, quad2r_y}, {quad3r_x, quad3r_y}, {quad4r_x, quad4r_y}] =   [
  {0..div(max_x,2)-1,0..div(max_y,2)-1},
  {div(max_x,2)+1..max_x,0..div(max_y,2)-1},
  {0..div(max_x,2)-1,div(max_y,2)+1..max_y},
  {div(max_x,2)+1..max_x,div(max_y,2)+1..max_y},
]

[{half1r_x, half1r_y}, {half2r_x, half2r_y}] =   [
  {0..div(max_x,2)-1,0..max_y},
  {div(max_x,2)+1..max_x,0..max_y},
]

# [{half1r_x, half1r_y}, {half2r_x, half2r_y}] =   [
#   {0..max_x,0..div(max_y,2)-1},
#   {0..max_x,div(max_y,2)+1..max_y},
# ]

{bots,_} = 1..100000
|> Enum.reduce_while({security_bots, MapSet.new()}, fn i, {security_bots, history} ->
  bots = security_bots
  |> Enum.map(fn {{p_x,p_y}, {v_x,v_y}} ->
    n_x = p_x + v_x
    n_y = p_y + v_y

    n_x = case n_x do
      x when x < 0 -> max_x + (n_x+1)
      x when x > max_x -> rem(n_x, max_x) - 1
      _ -> n_x
    end

    n_y = case n_y do
      y when y < 0 -> max_y + (n_y+1)
      y when y > max_y -> rem(n_y, max_y) - 1
      _ -> n_y
    end

    {{n_x, n_y},{v_x,v_y}}
  end)


  # [quad1, quad2, quad3, quad4] = bots
  #   |> Enum.group_by(fn {{p_x, p_y}, _} ->
  #     cond do
  #       p_x in quad1r_x && p_y in quad1r_y -> 1
  #       p_x in quad2r_x && p_y in quad2r_y -> 2
  #       p_x in quad3r_x && p_y in quad3r_y -> 3
  #       p_x in quad4r_x && p_y in quad4r_y -> 4
  #       true -> nil
  #     end
  #   end)
  #   |> Enum.filter(fn {k, g} -> k != nil end)
  #   |> Enum.map(fn {k, g} -> Enum.uniq_by(g, fn {p,_} -> p end) |> Enum.count() end)


  # [half1, half2] = bots
  #   |> Enum.group_by(fn {{p_x, p_y}, _} ->
  #     cond do
  #       p_x in half1r_x && p_y in half1r_y -> 1
  #       p_x in half2r_x && p_y in half2r_y -> 2
  #       true -> nil
  #     end
  #   end)
  #   |> Enum.filter(fn {k, g} -> k != nil end)
  #   |> Enum.map(fn {k, g} -> Enum.uniq_by(g, fn {p,_} -> p end) |> Enum.count() end)

  #   [half1, half2] = bots
  #   |> Enum.group_by(fn {{p_x, p_y}, _} ->
  #     cond do
  #       p_x in half1r_x && p_y in half1r_y -> 1
  #       p_x in half2r_x && p_y in half2r_y -> 2
  #       true -> nil
  #     end
  #   end)
  #   |> Enum.filter(fn {k, g} -> k != nil end)
  #   |> Enum.map(fn {k, g} -> g |> Enum.map(fn {p,_} -> p end) |> Enum.into(MapSet.new()) end)

  # matches = half2 |> Enum.count(fn {x,y} ->
  #   # IO.inspect({x,y})
  #   # IO.inspect({x, half1r_y.last - (x - half2r_y.first)})
  #   # !MapSet.member?(half1, {x, half1r_y.last - (x - half2r_y.first)})
  #   MapSet.member?(half1, {half1r_x.last - (x - half2r_x.first), y})
  # end)


# |> IO.inspect(charlists: :as_lists)

# [quad1, quad2, quad3, quad4] = quads
# |> Enum.map(fn {xr,yr} ->
  #   xr |> Enum.flat_map(fn x ->
    #     yr |> Enum.map(fn y ->
      #       bots |> Enum.count(fn {p, _} ->
        #         p == {x,y}
        #       end)
        #     end)
        #   end)
        #   |> Enum.sum()
        #   # |> IO.inspect()
        # end)

  # if (quad1 == quad3 && quad2 == quad4) do
  # if (half1 == half2) do

  IO.inspect(i)
  bots_pos = bots |> Enum.map(&(elem(&1, 0))) |> Enum.into(MapSet.new())
  0..max_y
  |> Enum.map(fn y ->
    0..max_x
    |> Enum.map(fn x ->
      if (MapSet.member?(bots_pos, {x,y})) do
        IO.write("#")
      else
        IO.write(".")
      end
    end)
    IO.write("\n")
  end)
  IO.write("\n")

  if (MapSet.member?(history, bots)) do
    {:halt, {bots, MapSet.put(history, bots)}}
  else
    {:cont, {bots, MapSet.put(history, bots)}}
  end

end)

[
  {0..div(max_x,2)-1,0..div(max_y,2)-1},
  {0..div(max_x,2)-1,div(max_y,2)+1..max_y},
  {div(max_x,2)+1..max_x,0..div(max_y,2)-1},
  {div(max_x,2)+1..max_x,div(max_y,2)+1..max_y},
]
|> IO.inspect()
|> Enum.map(fn {xr,yr} ->
  xr |> Enum.flat_map(fn x ->
    yr |> Enum.map(fn y ->
      bots |> Enum.count(fn {p, _} ->
        p == {x,y}
      end)
    end)
  end)
  |> Enum.sum()
  # |> IO.inspect()
end)
|> Enum.product()
|> IO.inspect()

# bots_pos = bots |> Enum.map(&(elem(&1, 0))) |> Enum.into(MapSet.new())

# 0..max_y
# |> Enum.map(fn y ->
#   0..max_x
#   |> Enum.map(fn x ->
#     if (MapSet.member?(bots_pos, {x,y})) do
#       IO.write("#")
#     else
#       IO.write(".")
#     end
#   end)
#   IO.write("\n")
# end)

# 94a+34b = 8400
# 94a+34b-8400=22a+67b-5400
# 94a-22a=67b-34b-5400+8400
# a=(67b-34b-5400+8400)/(94-22)

# b=8400-94a
# b=8400-94((67b-34b-5400+8400)/(94-22))
IO.puts(System.os_time(:millisecond) - start)
