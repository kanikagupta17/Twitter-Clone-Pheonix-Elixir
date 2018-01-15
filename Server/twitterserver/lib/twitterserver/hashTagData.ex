defmodule HashTagData do
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
    
    hashTagMap = :ets.new(:hashTagMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :hashTags)
    
  end

  def handle_cast({:AddHashTag,hashTag,tweetId},state) do
    list = :ets.lookup(:hashTagMap, hashTag)
    if(length(list) == 0) do
      hashTagTweetsList = [tweetId]
    else
      hashTagTweetsList = Enum.fetch!(list,0) |> elem(1)  
      hashTagTweetsList = [tweetId] ++ hashTagTweetsList  
    end
    :ets.insert(:hashTagMap, {hashTag,hashTagTweetsList})
    {:noreply,state}
  end

  def handle_call({:GetTweetsForHashTag,hashTag},_from,state) do
    list = :ets.lookup(:hashTagMap, hashTag)
    hashTagTweetsList = []
    if(length(list) > 0) do
      hashTagTweetsList = Enum.fetch!(list,0) |> elem(1) |> Enum.take(100)
    end

    {:reply,hashTagTweetsList,state}
  end

end
