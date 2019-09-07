defmodule Parent do
  use Supervisor

  def start_link(args) do
    start = :os.system_time(:nanosecond)
    Supervisor.start_link(__MODULE__,args)
    stop = :os.system_time(:nanosecond) - start
    IO.puts "Time taken - " <> Integer.to_string(stop)
  end

  def init(args) do
    n1 = IO.gets "Input1 "
    n1 = String.trim(n1)
    n1 = String.to_integer(n1)    # convert string to integer

    n2 = IO.gets "Input2 "
    n2 = String.trim(n2)
    n2 = String.to_integer(n2)
    limits = Enum.to_list(n1..n2)
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
    doSome(limit)#IO.puts "Start child with limit #{limit} pid #{inspect self()}"
  end


  def doSome(num) do
    s = Integer.to_string(num)   #IO.puts "Integer #{is_integer(s)}"
    len = String.length(s)

    if rem(len, 2)==0 do
      permute(s, num)
    end
  end


  #####################################################################
  def permute(s, num) do
    len = String.length(s)
    #list = String.split(s, "", trim: true)

    sorted = Enum.sort(String.codepoints("#{num}"))
    vf = Enum.filter(factor_pairs(num), fn {a, b} ->
      length(to_char_list(a))==div(len,2) && length(to_char_list(b))==div(len,2) &&
        Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
        Enum.sort(String.codepoints("#{a}#{b}")) == sorted
    end)

    if vf != [] do
      a = Enum.map(vf, fn{a,b} ->
        " #{a} #{b} "
      end)
      IO.puts("#{num} #{a}")
    end
  end

  def factor_pairs(num) do
    first = trunc(num / :math.pow(10, div(length(to_char_list(num)), 2)))
    last  = :math.sqrt(num) |> round
    for i <- first .. last, rem(num, i) == 0, do: {i, div(num, i)}
  end

end
#
#
Parent.start_link(1)
#
#Process.sleep 10_0000