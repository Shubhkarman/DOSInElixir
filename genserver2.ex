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
  def handle_cast({:subtask, n1, n2, parentPID}, state) do
    result = print_multiple_times(n1, n2)
    #IO.puts "Here is the output for task "
    result = result |> elem(1)
    #IO.puts result
    send(parentPID, result)
    {:noreply, [state]}
  end

  def print_multiple_times(n1, n2) when n1 == n2 do
    s = Integer.to_string(n1)
    len = String.length(s)
    result = if rem(len, 2)==0 do
      permute(s, n1) |> elem(1)
    else
      ""
    end
    #IO.puts "Value of result at 1 is: #{result}"
    {:ok, result}
  end

  def print_multiple_times(n1, n2) do
    s = Integer.to_string(n1)
    len = String.length(s)
    result = if rem(len, 2)==0 do
      result = permute(s, n1) |> elem(1)
    else
      ""
    end
    temp = print_multiple_times(n1+1, n2) |> elem(1)
    #IO.puts "Value of result at 1 is: #{result}"
    #IO.puts "Value of temp at 2 is: #{temp}"
    temp1 = if result == "" do
      ""
    else
      "\n"
    end
    result = result <> temp1 <> temp
    #IO.puts "Value of result at 3 is: #{result}"
    {:ok, result}
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

    result = if vf != [] do
      a = Enum.map(vf, fn{a,b} ->
        " #{a} #{b} "
      end)
      "#{num} #{a}"
    else
      ""
    end
    {:ok, result}
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
    workunit = 100#getWorkUnit(n)
    numworkers = getNumOfWorkers(n2-n1, workunit)
    IO.puts "numworkers  #{numworkers}"
    loop(numworkers, workunit, n1, n2)
    result = waitForAllWorkersToFinish(numworkers) |> elem(1)
    IO.puts result
    stop = :os.system_time(:nanosecond) - start
    IO.puts "Time taken - " <> Integer.to_string(stop)
  end

  @doc """
  Start async processes by using Genserver.cast
  """
  def loop(numworkers, workunit, n1, n2) do
    if numworkers>0 do
      {:ok, pid} = GenServer.start_link(DosProject, [:subtask], [])
      i = n1 + ((numworkers * workunit) - workunit) + 1
      GenServer.cast(pid, {:subtask, i, n2, self()})

      DosProject.loop(numworkers - 1, workunit, n1, i-1)

    end
  end

  @doc """
  Wait for all workers to finish processing all numbers in batches and send response.
  """
  def waitForAllWorkersToFinish(numWorkers) do
    result = if numWorkers>0 do
      msg = receive do msg ->
        msg
      end
      msg = String.trim(msg)
      temp = waitForAllWorkersToFinish(numWorkers-1) |> elem(1)
      temp1 = if msg == "" do
        ""
      else
        "\n"
      end
      msg = msg <> temp1 <> temp
    else
      ""
    end
    {:ok, result}
  end

  @doc """
  Total number of workers spawned
  """
  def getNumOfWorkers(n,workunit) do
    n/workunit |> Float.ceil |> Kernel.trunc
  end
end

#Run this -
#DosProject.start(1,1000000)