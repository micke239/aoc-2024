#Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])
:ets.insert(:my_secret_test, {"cache", Map.new()})

defmodule Funcs do
  def parse([], values) do
    values
  end
  def parse(chain, values) do
      res = find_first(chain, fn {v1,_o,v2,_t} ->
        Map.has_key?(values, v1) && Map.has_key?(values, v2)
      end, [])

      if res == nil do
        nil
      else
        {{v1,o,v2,t}, n_chain} = res
        n_v = case o do
          "XOR" -> values[v1] != values[v2]
          "OR" -> values[v1] || values[v2]
          "AND" -> values[v1] && values[v2]
        end

        parse(n_chain, Map.put(values, t, n_v))
      end

  end

  def find_first([], _, _) do
    nil
  end
  def find_first([e | rest], pred, handled) do
    if pred.(e) do
      {e, Enum.reverse(handled) ++ rest}
    else
      find_first(rest, pred, [e | handled])
    end
  end

  def find_dependencies(z, chain, found) do
    cond do
      String.starts_with?(z, "x") -> found
      String.starts_with?(z, "y") -> found
      true ->
        {v1,_,v2,_} = chain |> Enum.find(fn {_,_,_,to} -> to == z end)
        f1 = find_dependencies(v1,chain,[z | found])
        f2 = find_dependencies(v2,chain,[z | found])

        f1 ++ f2
    end
  end

  def expand_dependencies(z, chain) do
    cond do
      String.starts_with?(z, "x") -> z
      String.starts_with?(z, "y") -> z
      true ->
        {v1,op,v2,_} = chain |> Enum.find(fn {_,_,_,to} -> to == z end)

        e1 = expand_dependencies(v1, chain)
        e2 = expand_dependencies(v2, chain)

        "(#{e1}) #{op} (#{e2})"
    end
  end

end

start_t = System.os_time(:millisecond)



[start_input, chain_input] =
  File.read!("input/day24.txt")
  |> String.split("\n\n")


values = start_input
  |> String.split("\n")
  |> Enum.map(fn x ->
    [k,v] = String.split(x, ": ")

    {k,v == "1"}
  end)
  |> Enum.into(Map.new())

chain = chain_input
  |> String.split("\n")
  |> Enum.map(fn l ->
    [f,t] = String.split(l, " -> ")

    [v1,o,v2] = String.split(f, " ")
    # qff,qnw
# pbv,z15
# qqp,z23
# fbq,z37
    t = case t do
      "qff" -> "qnw"
      "qnw" -> "qff"

      "pbv" -> "z16"
      "z16" -> "pbv"

      "qqp" -> "z23"
      "z23" -> "qqp"

      "fbq" -> "z36"
      "z36" -> "fbq"

      _ -> t
    end

    {v1, o, v2, t}
  end)

ouput = Funcs.parse(chain,values) |> IO.inspect()

byte = ouput
|> Enum.filter(fn {k,_x} -> String.starts_with?(k, "z") end)
|> Enum.sort_by(fn {k,v} -> k end)
|> Enum.reduce("", fn {k,v}, acc ->
  if (v) do
    "1" <> acc
  else
    "0" <> acc
  end
end)
|> String.to_integer(2)
|> IO.inspect()

#part2


byte = ouput
|> Enum.filter(fn {k,_x} -> String.starts_with?(k, "z") end)
|> Enum.sort_by(fn {k,v} -> k end)
|> Enum.reduce("", fn {k,v}, acc ->
  if (v) do
    "1" <> acc
  else
    "0" <> acc
  end
end)

byte
|> String.to_integer(2)
|> IO.inspect()


IO.puts(System.os_time(:millisecond) - start_t)

y_v = values
|> Enum.filter(fn {k,_x} -> String.starts_with?(k, "y") end)
|> Enum.sort_by(fn {k,v} -> k end)
|> Enum.reduce("", fn {k,v}, acc ->
  if (v) do
    "1" <> acc
  else
    "0" <> acc
  end
end)
|> String.to_integer(2)
|> IO.inspect()

x_v = values
|> Enum.filter(fn {k,_x} -> String.starts_with?(k, "x") end)
|> Enum.sort_by(fn {k,v} -> k end)
|> Enum.reduce("", fn {k,v}, acc ->
  if (v) do
    "1" <> acc
  else
    "0" <> acc
  end
end)
|> String.to_integer(2)
|> IO.inspect()

expected_output = x_v + y_v |> IO.inspect()
# expected_output = Bitwise.band(x_v,y_v) |> IO.inspect()

outputs = chain |> Enum.map(fn {_,_,_,t} -> t end)

output_combos = for x <- outputs, y <- outputs, x != y, do: {x, y}

byte |> IO.inspect()
expected_output_bytes = expected_output |> Integer.to_string(2) |>IO.inspect()

expected_output_indexed = expected_output_bytes |> String.graphemes() |> Enum.with_index()

to_change = byte
|> String.graphemes()
|> Enum.with_index()
|> Enum.filter(fn {v,i} ->
  {v2,_} = expected_output_indexed |> Enum.find(fn {_,i2} -> i == i2 end)
  v != v2
end)
|> Enum.map(fn {v,i} -> {if i < 10 do "z0#{i}" else "z#{i}" end, v == "1" } end)
|> Enum.into(Map.new())
|> IO.inspect()

interesting = outputs
|> Enum.filter(&(String.starts_with?(&1, "z")))
|> Enum.sort()
|> Enum.each(fn z ->
  deps = Funcs.expand_dependencies(z, chain)
  IO.puts("#{z} = #{deps}")
end)


interesting = outputs
|> Enum.filter(&(String.starts_with?(&1, "z")))
#|> Enum.filter(&(Map.has_key?(to_change, &1)))
|> Enum.map(fn z ->
  {v1,_,v2,_} = chain |> Enum.find(fn {_,_,_,to} -> to == z end)
  f1 = Funcs.find_dependencies(v1,chain,[])
  f2 = Funcs.find_dependencies(v2,chain,[])

  {z, (f1 ++ f2) |> Enum.uniq()}
end)

interesting = outputs
|> Enum.filter(&(String.starts_with?(&1, "z")))
|> Enum.sort()
|> Enum.map(fn z ->
  chain
  |> Enum.filter(fn {_,_,_,to} -> to == z end)
  |> IO.inspect()
  |> Enum.map(fn {v1,_,v2,to} ->
    IO.puts("")

    IO.write("  ")

    chain
    |> Enum.filter(fn {_,_,_,to} -> to == v1 end)
    |> IO.inspect()
    |> Enum.map(fn {v1,_,v2,to} ->
      IO.write("    ")
      chain
      |> Enum.filter(fn {_,_,_,to} -> to == v1 end)
      |> IO.inspect()
      IO.write("    ")
      chain
      |> Enum.filter(fn {_,_,_,to} -> to == v2 end)
      |> IO.inspect()

    end)

    IO.write("  ")

    chain
    |> Enum.filter(fn {_,_,_,to} -> to == v2 end)
    |> IO.inspect()
    |> Enum.map(fn {v1,_,v2,to} ->
      IO.write("    ")
      chain
      |> Enum.filter(fn {_,_,_,to} -> to == v1 end)
      |> IO.inspect()
      IO.write("    ")
      chain
      |> Enum.filter(fn {_,_,_,to} -> to == v2 end)
      |> IO.inspect()

    end)

    IO.puts("=================")
  end)
end)
#z16 ska ha or och xor
# z23,z16,z36,z45 (?)
# qff,qnw
# pbv,z15
# qqp,z23
# fbq,z37

# "qff" -> "qnw"
# "qnw" -> "qff"

# "pbv" -> "z16"
# "z16" -> "pbv"

# "qqp" -> "z23"
# "z23" -> "qqp"

# "fbq" -> "z36"
# "z36" -> "fbq"

["qff","qnw","pbv","z16","qqp","z23","fbq","z36"] |> Enum.sort() |> Enum.join(",") |> IO.puts()



#qqp,z23

# |> IO.inspect()
# |> Enum.group_by(fn {k,v} -> v end, fn {k,v} -> k end)
# |> Enum.filter(fn {_,v} -> Enum.all?(v, &(Map.has_key?(to_change, &1))) end)
# |> Enum.flat_map(fn {k,v} -> Enum.map(v, fn v -> {v,k} end) end)
# |> Enum.group_by(fn {k,v} -> k end, fn {k,v} -> v end)
# |> Enum.flat_map(fn {k,v} -> v end)
# |> Enum.uniq()
# |> Enum.filter(fn {k,v} -> Enum.count(v) == 1 end)
# |> Enum.map(fn {k,v} -> IO.inspect({elem(Enum.at(v,0),0),k}) end)
# |> IO.inspect()
# |> IO.inspect()

# output_combos = interesting
# |> Enum.flat_map(fn i ->
#   interesting
#     |> Enum.drop_while(fn x -> x != i end)
#     |> Enum.drop(1)
#     |> Enum.map(fn x -> {i,x} end)
# end)

# output_combos_4 = output_combos
# |> Enum.flat_map(fn i1 ->
#   output_combos
#     |> Enum.drop_while(fn x -> x != i1 end)
#     |> Enum.drop(1)
#     |> Enum.flat_map(fn i2 -> output_combos
#       |> Enum.drop_while(fn x -> x != i2 end)
#       |> Enum.drop(1)
#       |> Enum.flat_map(fn i3 -> output_combos
#         |> Enum.drop_while(fn x -> x != i3 end)
#         |> Enum.drop(1)
#         |> Enum.map(fn x -> {i1,i2,i3,x} end)
#       end)
#     end)
# end)

# output_combos |> Enum.count() |> IO.inspect()
# output_combos_4 |> Enum.count() |> IO.inspect()

# output_combos_4 |> IO.inspect()

# {s,_,_,_} = output_combos_4
# |> Enum.reduce({[], to_change, chain, byte}, fn [t1,t2,t2,t3], {swaps, to_change, chain, current_output_bytes} ->
#   n_swap = [{t1,t2} | swaps]


#   n_chain = chain
#     |> Enum.map(fn {v1,o,v2,t} ->
#       cond do
#         t == t2 ->  {v1,o,v2,t1}
#         t == t2 -> {v1,o,v2,t2}
#         true -> {v1,o,v2,t}
#       end
#     end)

#   output = Funcs.parse(n_chain,values)

#   if output == nil do
#     {swaps, to_change, chain, current_output_bytes}
#   else
#     h = to_change |> Enum.filter(fn {k,v} -> output[k] != v end)

#     if (Enum.any?(h)) do
#       {n_swap, Enum.filter(to_change, fn x -> !Enum.any?(h, fn y -> x == y end) end), n_chain, current_output_bytes}
#     else
#       {swaps, to_change, chain, current_output_bytes}
#     end
#   end
# end)


# IO.inspect(s)

#1011 0011 1101 00111 0110 1100 1001 0001 1111 0111 00110
#1011 0100 0001 00111 0111 0000 1001 0010 0011 0111 00110

#6,7,8,9,10,
