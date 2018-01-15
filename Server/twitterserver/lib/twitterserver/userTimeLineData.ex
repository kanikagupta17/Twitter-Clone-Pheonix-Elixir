defmodule UserTimeLineData do
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
  def start_link(opts \\ []) do
    
    userTimeLineMap = :ets.new(:userTimeLineMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :userTimeLine)
    
  end

  def handle_cast({:AddTweetToUserTimeLine,userName,tweetId},state) do
    list = :ets.lookup(:userTimeLineMap, userName)
    if(length(list) == 0) do
      userTweetsList = [tweetId]
    else
      userTweetsList = Enum.fetch!(list,0) |> elem(1)  
      userTweetsList = [tweetId] ++ userTweetsList  
    end
    :ets.insert(:userTimeLineMap, {userName,userTweetsList})
    {:noreply,state}
  end
  
  def handle_call({:GetUserTimeLine,userName},_from,state) do
    list = :ets.lookup(:userTimeLineMap, userName)
    resultList = []
    if(length(list) > 0) do
      fullList = Enum.fetch!(list,0) |> elem(1)
      resultList = Enum.take(fullList, 100)
    end

    {:reply,resultList,state}
  end

end
