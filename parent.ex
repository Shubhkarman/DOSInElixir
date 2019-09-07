defmodule Parent do
  def main do
    Process.flag :trap_exit, true
    IO.puts "before"
    spawn_link (fn() -> IO.puts "sleep";Process.sleep 3000; :ok end)
    #Process.sleep 100
    IO.puts "after1"

    receive do
      msg -> IO.inspect msg, label: "received message"
    end

    IO.puts "after2"

  end


end

Parent.main()