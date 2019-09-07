defmodule DosProject do
  use GenServer
  @moduledoc """
  Documentation for DosProject.
  """

  #Worker (server) methods
  @impl true
  def init(args) do
    {:ok, args}
  end

  @doc """
  Handle async calls
  """
  @impl true
  def handle_cast({:subtask, n1, n2}, state) do
    print_multiple_times(n1, n2)
    {:noreply, [state]}
  end

  def print_multiple_times(n1, n2) when n1 == n2 do
    s = Integer.to_string(n1)
    len = String.length(s)

    if rem(len, 2)==0 do
      permute(s, n1)
    end
  end

  def print_multiple_times(n1, n2) do
    s = Integer.to_string(n1)
    len = String.length(s)

    if rem(len, 2)==0 do
      permute(s, n1)
    end

    print_multiple_times(n1+1, n2)
  end

  #####################################################################
  def permute(s,num) do
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


  # Supervisor (client) methods

  @doc """
  Use for starting sub tasks for the main problem
  """
  def start(n1,n2) do
    start = :os.system_time(:nanosecond)
    workunit = 1000#getWorkUnit(n)
    numworkers = getNumOfWorkers(n2-n1+1, workunit)
    IO.puts "numworkers  #{numworkers}"
    loop(numworkers, workunit, n1, n2)
    stop = :os.system_time(:nanosecond) - start
    IO.puts "Time taken - " <> Integer.to_string(stop)
  end

  @doc """
  Start async processes by using Genserver.cast
  """
  def loop(numworkers, workunit, n1, n2) do
    if numworkers>0 do
      {:ok, pid} = GenServer.start_link(DosProject, [:subtask], [])
      i = ((numworkers * workunit) - workunit) + 1
      GenServer.cast(pid, {:subtask, i, n2})

      DosProject.loop(numworkers - 1, workunit, n1, i-1)

    end
  end

  @doc """
  Total number of workers spawned
  """
  def getNumOfWorkers(n,workunit) do
    n/workunit |> Float.ceil |> Kernel.trunc
  end

  @doc """
  Total number of calculations performed by each worker
  """
  def getWorkUnit(n) do
    logn = :math.log(n)/2.303 |> round
    if (logn == 1) do
      n
    else
      :math.pow(10, round(logn/2)) |> trunc
    end
  end
end

#Run this -
#DosProject.start(1,1000000)