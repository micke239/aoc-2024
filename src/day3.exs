Code.require_file("utilities.ex", "./src")

start = System.os_time(:millisecond)

input = File.read!("input/day3.txt")

defmodule Funcs do

end

mul_reg = ~r/mul\((\d{1,3}),(\d{1,3})\)/

Regex.scan(mul_reg, input)
  |> Enum.map(fn l ->
    l
    |> Enum.drop(1)
    |> Enum.map(&(String.to_integer(&1)))
    |> Enum.product()
  end)
  |> Enum.sum()
  |> IO.inspect()

do_reg = ~r/do\(\)/
dont_reg = ~r/don't\(\)/

dos = Regex.scan(do_reg, input, return: :index)
  |> Enum.map(fn [{ x, _ } | []] -> x end)

donts = Regex.scan(dont_reg, input, return: :index)
  |> Enum.map(fn [{ x, _ } | []] -> x end)

illegal = donts
  |> Enum.map(fn x ->
    y = dos |> Enum.drop_while(fn h -> h < x end) |> Enum.at(0)
    {x, y}
  end)

Regex.scan(mul_reg, input, return: :index)
  |> Enum.map(fn l ->
    list2 = l
    |> Enum.filter(fn {x,_} ->
      !(illegal |> Enum.any?(fn {z,k} -> x > z && x < k end))
    end)
    |> Enum.map(fn {x,y} ->
      String.slice(input, x..(x+y-1))
     end)
    |> Enum.drop(1)
    |> Enum.map(&(String.to_integer(&1)))

    if (Enum.empty?(list2)) do
      0
    else
      list2 |> Enum.product()
    end
  end)
  |> Enum.sum()
  |> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
