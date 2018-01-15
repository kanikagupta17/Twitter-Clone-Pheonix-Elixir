defmodule UserMentionsData do
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
    
    userMentionsMap = :ets.new(:userMentionsMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :userMentions)
    
  end

  def handle_cast({:AddUserMention,mentionedUser,tweetId},state) do
    list = :ets.lookup(:hashTagMap, mentionedUser)
    if(length(list) == 0) do
      userMentionsTweetsList = [tweetId]
    else
      userMentionsTweetsList = Enum.fetch!(list,0) |> elem(1)  
      userMentionsTweetsList = [tweetId] ++ userMentionsTweetsList  
    end
    :ets.insert(:userMentionsMap, {mentionedUser,userMentionsTweetsList})
    {:noreply,state}
  end

  def handle_call({:GetTweetsForMentionedUser,mentionedUser},_from,state) do
    list = :ets.lookup(:userMentionsMap, mentionedUser)
    userMentionsTweetsList = []
    if(length(list) > 0) do
      userMentionsTweetsList = Enum.fetch!(list,0) |> elem(1) |> Enum.take(100)
    end

    {:reply,userMentionsTweetsList,state}
  end

end
