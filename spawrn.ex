defmodule Spawn do
  def main do
#    n1 = IO.gets "Input1 "
#    n1 = String.trim(n1)
#    n1 = String.to_integer(n1)    # convert string to integer
#
#    n2 = IO.gets "Input2 "
#    n2 = String.trim(n2)
#    n2 = String.to_integer(n2)

    start = :os.system_time(:nanosecond)
    spawn_link fn() ->mapPrint(1,10) end
    stop = :os.system_time(:nanosecond) - start
    IO.puts "time taken " <>  Integer.to_string(stop)

  end

  def mapPrint(n1, n2) do
    Enum.map(n1..n2, fn number -> spawn_link(fn -> doSome end) end)

  end

  def doSome() do
    IO.puts("doiing")
  end

  end

Spawn.main()