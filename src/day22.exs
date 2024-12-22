#Code.require_file("utilities.ex", "./src")

import Bitwise

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"cache", Map.new()})

defmodule Funcs do

  def mix_and_prune(n, s) do
    n1 = bxor(n, s)
    rem(n1, 16777216)
  end

  def evolve_secret_number(n) do
    n1 = n * 64
    n1 = mix_and_prune(n1, n)

    n2 = div(n1,32)
    n2 = mix_and_prune(n2, n1)

    n3 = n2 * 2048
    n3 = mix_and_prune(n3, n2)

    n3
  end

end

start_t = System.os_time(:millisecond)



secret_numbers =
  File.read!("input/day22.txt")
  |> String.split("\n")
  |> Enum.map(&(String.to_integer(&1)))

#part1


secret_numbers
|> Enum.map(fn n ->
  1..2000
  |> Enum.reduce(n, fn _i, acc ->
    Funcs.evolve_secret_number(acc)
  end)
end)
|> Enum.sum()
|> IO.inspect()

#part2

secret_numbers
|> Enum.reduce(Map.new(), fn n, acc ->
  {_,cache,_} = 1..2000
  |> Enum.reduce({n, Map.new(), {nil,nil,nil,nil}}, fn i, {acc, cache, {p1,p2,p3,_p4}} ->
    n_acc = Funcs.evolve_secret_number(acc)

    price = rem(acc, 10)
    n_price = rem(n_acc, 10)
    diff = n_price - price
    case i do
      1 -> {n_acc, cache, {diff,nil,nil,nil}}
      2 -> {n_acc, cache, {diff,p1,nil,nil}}
      3 -> {n_acc, cache, {diff,p1,p2,nil}}
      _ ->
        ps = {diff,p1,p2,p3}
        {n_acc, Map.put_new(cache, ps, n_price), ps}
    end
  end)

  Map.merge(acc, cache, fn _k,v1,v2 -> v1+v2 end)
end)
|> Enum.map(fn {_k,v} -> v end)
|> Enum.max()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start_t)
