defmodule NewsFeedData do
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
    
    newsFeedMap = :ets.new(:newsFeedMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :newsFeed)
    
  end

  def handle_cast({:AddTweetToNewsFeed,userName,tweetId},state) do
    list = :ets.lookup(:newsFeedMap, userName)
    if(length(list) == 0) do
      newsFeedTweetsList = [tweetId]
    else
      newsFeedTweetsList = Enum.fetch!(list,0) |> elem(1)  
      newsFeedTweetsList = [tweetId] ++ newsFeedTweetsList  
    end
    :ets.insert(:newsFeedMap, {userName,newsFeedTweetsList})
    {:noreply,state}
  end

  def handle_call({:GetFullNewsFeed,userName},_from,state) do
    [{_, newsFeedTweetsList}]= :ets.lookup(:newsFeedMap, userName)
    {:reply,newsFeedTweetsList,state}
  end

  def handle_call({:GetRecentNewsFeed,userName},_from,state) do
    list = :ets.lookup(:newsFeedMap, userName)
    resultList = []
    if(length(list) > 0) do
      resultList = Enum.fetch!(list,0) |> elem(1) |> Enum.take(100)
    end

    {:reply,resultList,state}
  end

end
