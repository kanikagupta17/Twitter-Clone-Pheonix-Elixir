defmodule Tweets do
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
    tweetCounterTable = :ets.new(:tweetCounterTable, [:named_table,:public])
    :ets.insert(:tweetCounterTable, {"tweetCounter",0})
    tweetsMap = :ets.new(:tweetsMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :tweets)
    
  end

  def handle_call({:PutTweet,tweet}, _from,state) do
    ##use size of tweettable
    tweetId = :ets.update_counter(:tweetCounterTable, "tweetCounter", {2,1})
    :ets.insert(:tweetsMap, {tweetId,tweet})
    {:reply, tweetId,state}
  end

  def handle_call({:GetTweetById,tweetId},_from,state) do
    [{_, tweet}] = :ets.lookup(:tweetsMap, tweetId)
    {:reply,tweet,state}
  end

  def handle_cast({:DeleteTweetById,tweetId},state) do
    :ets.delete(:tweetsMap, tweetId)
    {:noreply,state}
  end

end
