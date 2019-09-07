defmodule Parent do
  use Supervisor

  def start_link(limits) do
    Supervisor.start_link(__MODULE__, limits)
  end

  def init(limits) do
    children = Enum.map(limits, fn(limit_num) ->
      worker(Child, [limit_num], [id: limit_num, restart: :permanent])
    end)

    supervise(children, strategy: :one_for_one)
  end
end

defmodule Child do
  def start_link(limit) do
    pid = spawn_link(__MODULE__, :init, [limit])
    {:ok, pid}
  end

  def init(limit) do
    IO.puts "Start child with limit #{limit} pid #{inspect self()}"
    loop(limit)
  end

  def loop(0), do: :ok
  def loop(n) when n > 0 do
    IO.puts "Process #{inspect self()} counter #{n}"
    Process.sleep 500
    loop(n-1)
  end
end


Parent.start_link([2,3,5])

Process.sleep 10_000










defmodule Recursion do
  def main do

    start = :os.system_time(:nanosecond)
    #print_multiple_times(1, 100000)
    stop = :os.system_time(:nanosecond) - start
    IO.puts "Time taken linearly - " <> Integer.to_string(stop)

    start2 = :os.system_time(:nanosecond)
    print_multiple_times_parallel(1, 100000)
    stop2 = :os.system_time(:nanosecond) - start2
    IO.puts "Time taken in parallel - " <> Integer.to_string(stop2)


  end
  #####################################################################
  def print_multiple_times(n1, n2) when n1 == n2 do
    s = Integer.to_string(n1)   #IO.puts "Integer #{is_integer(s)}"
    len = String.length(s)

    if rem(len, 2)==0 do
      permute(s, n1)
    end
  end

  def print_multiple_times(n1, n2) do
    s = Integer.to_string(n1)   #IO.puts "Integer #{is_integer(s)}"
    len = String.length(s)

    if rem(len, 2)==0 do
      permute(s, n1)
    end

    print_multiple_times(n1+1, n2)
  end

  #####################################################################
  def print_multiple_times_parallel(n1, n2) when n1 == n2 do
    s = Integer.to_string(n1)   #IO.puts "Integer #{is_integer(s)}"
    len = String.length(s)

    if rem(len, 2)==0 do
      spawn fn() -> permute(s, n1) end
    end
  end

  def print_multiple_times_parallel(n1, n2) do
    s = Integer.to_string(n1)   #IO.puts "Integer #{is_integer(s)}"
    len = String.length(s)

    if rem(len, 2)==0 do
      spawn fn() -> permute(s, n1) end
    end

    print_multiple_times_parallel(n1+1, n2)
  end
  #####################################################################
  def permute(s, num) do
    len = String.length(s)
    list = String.split(s, "", trim: true)

    # mapp_set = MapSet.new()
    first = 1
    Enum.map(permutation(list), fn x ->
      x = Enum.join(x, "")

      zero = "0"
      s1 = String.slice(x, 0, div(len, 2))
      s2 = String.slice(x, div(len, 2), len)
      list1 = String.codepoints(s1)
      list2 = String.codepoints(s2)
      n1 = String.to_integer(s1)
      n2 = String.to_integer(s2)

      f1 = hd(list1)
      l1 = List.last(list1)

      f2 = hd(list2)
      l2 = List.last(list2)

      flag = if (f1==zero || f2==zero || (l1==zero && l2==zero)) do
        1
      end

      prin = if flag != 1 && n1*n2 == num  do
        1
      end

      if prin==1 && first==1 do
        IO.puts "#{num} #{s1} #{s2}"
      end

    end)

  end

  defp permutation([]), do: [[]]
  defp permutation(list) do
    for x <- list, y <- permutation(list -- [x]), do: [x|y]
  end

end

#IO.inspect Recursion.permutation([1, 2, 3])
Recursion.main