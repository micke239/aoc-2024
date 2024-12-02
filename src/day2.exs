Code.require_file("utilities.ex", "./src")

start = System.os_time(:millisecond)

input = File.read!("input/day2.txt")

defmodule Funcs do
  def is_safe([start | rest], increasing, deploy_problem_dampener) do
      {_, success, _} = rest
        |> Enum.reduce_while(
          {start, true, !deploy_problem_dampener},
          fn x, {prev, last_cont, dampener_triggered} ->
            if !last_cont do
              {:halt, {prev, last_cont, dampener_triggered}}
            else
              cont = case increasing do
                true -> prev - x <= 3 && prev - x > 0
                false -> x - prev <= 3 && x - prev > 0
              end

              if !cont && !dampener_triggered do
                {:cont, {prev, true, true}}
              else
                {:cont, {x, cont, dampener_triggered}}
              end
            end
          end)

      success
  end
end

lists = input
|> String.split("\n")
|> Enum.map(fn line ->
  line
  |> String.split("\s")
  |> Enum.map(&(String.to_integer(&1)))
end)

lists
|> Enum.filter(fn list ->
  Funcs.is_safe(list, true, false) || Funcs.is_safe(list, false, false)
end)
|> Enum.count()
|> IO.inspect()

lists
|> Enum.filter(fn list ->
  reversed_list = Enum.reverse(list)

  safe1 = Funcs.is_safe(list, true, true)
  safe2 = Funcs.is_safe(list, false, true)
  safe3 = Funcs.is_safe(reversed_list, true, true)
  safe4 = Funcs.is_safe(reversed_list, false, true)

  safe1 || safe2 || safe3 || safe4
end)
|> Enum.count()
|> IO.inspect()





IO.puts(System.os_time(:millisecond) - start)
