defmodule Recursion do
  def main do
    n1 = IO.gets "Input1 "
    n1 = String.trim(n1)
    n1 = String.to_integer(n1)    # convert string to integer

    n2 = IO.gets "Input2 "
    n2 = String.trim(n2)
    n2 = String.to_integer(n2)

    start = :os.system_time(:nanosecond)
    print_multiple_times(n1, n2)
    stop = :os.system_time(:nanosecond) - start
    IO.puts stop

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

    if rem(len, 2)==0 do# rem is remainder
      permute(s, n1)
    end

    print_multiple_times(n1+1, n2)
  end
  #####################################################################
  def permute(s, num) do
    #list = String.codepoints(s)
    #l = permutation(list)
    #IO.puts l
    len = String.length(s)
    list = String.split(s, "", trim: true)

    mapp_set = MapSet.new()
    first = 1
    Enum.map(permutation(list), fn x ->
      x = Enum.join(x, "")

      zero = "0"
      s1 = String.slice(x, 0, div(len, 2))#first part
      s2 = String.slice(x, div(len, 2), len)#second part
      list1 = String.codepoints(s1)
      list2 = String.codepoints(s2)
      n1 = String.to_integer(s1)
      n2 = String.to_integer(s2)

      f1 = hd(list1)#first element of the list
      l1 = List.last(list1)#last element

      f2 = hd(list2)
      l2 = List.last(list2)

      flag = if (f1==zero || f2==zero || (l1==zero && l2==zero)) do#first should not be zero and last should not have more than 1 zero
        1
      end

      prin = if flag != 1 && n1*n2 == num  do
        1
      end

      if prin==1 && first==1 do
        IO.puts num
        first = 0
      end

      if ((prin==1) && (MapSet.member?(mapp_set, s1)==false) && (MapSet.member?(mapp_set, s2)==false)) do
        #IO.puts MapSet.member?(mapp_set, s1)
        #IO.puts MapSet.member?(mapp_set, s2)
        mapp_set = MapSet.put(mapp_set, s1)
        mapp_set |> MapSet.put(s1) |> MapSet.put(s1)

        mapp_set = MapSet.put(mapp_set, s2)
        mapp_set |> MapSet.put(s2) |> MapSet.put(s2)

        IO.puts s1
        IO.puts s2
        #IO.puts MapSet.member?(mapp_set, s1)
        #IO.puts MapSet.member?(mapp_set, s2)
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