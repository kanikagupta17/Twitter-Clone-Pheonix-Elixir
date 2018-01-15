defmodule StatsService do
  use GenServer
  @moduledoc """
  Documentation for Twitterserver.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Twitterserver.hello
      :world

  """
  def startStatService() do
    #statsTable = :ets.new(:statsTable, [:named_table,:public])
    #:ets.insert(:statsTable, {"TotalUsers",0})
    #:ets.insert(:statsTable, {"OnlineUsers",0})
    #:ets.insert(:statsTable, {"OfflineUsers",0})
    #:ets.insert(:statsTable, {"TotalTweets",0})
    
    Task.start(StatsService,:statsService,[])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :statsService)
    GenServer.cast(:statsService,{:getInput})
  end

  def handle_cast({:getInput},state) do


    input = IO.getn "PRESS Y and Enter to print stats in File "
    if (input == "y" || input == "Y"  ) do
      writeFollowersCountTofile()
    end
    {:noreply,state}
  end

  def writeFollowersCountTofile() do

    usersFollowerCountList=:ets.foldl( fn ({key, val},acc) -> acc=[MapSet.size(val)] ++ acc end, [], :followerMap)
    #list=[1,2,3,4,5,6,7,8]
    tocsv(usersFollowerCountList)
  end

  

  defp tocsv1(map) do
    File.open("test.csv", [:write, :utf8], fn(file) -> Enum.each(map, &IO.write(file, Enum.join(Tuple.to_list(&1), ?,) <> "\n"))    end)

    File.open("test.csv", [:write, :utf8], fn(file) -> Enum.each(map, fn(x) ->  IO.write(file, x <> "\n" ) end)    end)

    list = Enum.each(list, fn(x) -> IO.write(file, inspect(x)) end)
    IO.write(file, inspect(whatever))
  end

def tocsv(map) do
  {:ok, file} = File.open "zipf_results.csv", [:write]
  Enum.each(map, fn(x) -> IO.write(file, Integer.to_string(x)<>"\n") end)
  File.close file
  IO.puts "File Generated"
  #File.write!("test.csv", map|> Enum.join(Enum.join(Tuple.to_list(&1), ?,))|> Enum.join("\n"))
  #map|> IO.inspect |> CSV.encode |> Enum.each(&IO.write(file, &1))
end

  def statsService() do
    totalUsers = :ets.info(:usersTable)|>Enum.at(7)|>elem(1)|>Integer.to_string
    #:ets.insert(:statsTable, {"TotalUsers",totalUsers})
    onlineUsers = :ets.info(:activeUsersTable)|>Enum.at(7)|>elem(1)|>Integer.to_string
    #:ets.insert(:statsTable, {"OnlineUsers",onlineUsers})
    totalTweets = :ets.info(:tweetsMap)|>Enum.at(7)|>elem(1)|>Integer.to_string
    #:ets.insert(:statsTable, {"TotalTweets",totalTweets})
    #usersFollowerCountList=:ets.foldl( fn ({key, val},acc) -> acc=[length(val)] ++ acc end, [], :followerMap)
    #usersFollowerCountList=Enum.sort(usersFollowerCountList)
    #IO.write("n")
    IO.puts "\nTotal Users = "<> totalUsers
    IO.puts "\nOnline Users = "<> onlineUsers
    IO.puts "\nTotalTweets = "<> totalTweets
    IO.puts "\n"
    GenServer.cast(:statsService,{:getInput})
    :timer.sleep(5000);
    statsService()
  end

  

end
