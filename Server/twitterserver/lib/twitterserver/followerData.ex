defmodule FollowerData do
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
    
    followerMap = :ets.new(:followerMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :followers)
    
  end

  def handle_cast({:AddFollowerToUser,userName,followerUserName},state) do
    list = :ets.lookup(:followerMap, userName)
    if(length(list) == 0) do
        followerListSet = MapSet.new
    else
      followerListSet = Enum.fetch!(list,0) |> elem(1)    
    end
    
    followerListSet = MapSet.put(followerListSet, followerUserName)
    #IO.inspect followerListSet
    #IO.puts followerUserName <> "is now added in the follower list of " <> userName
    :ets.insert(:followerMap, {userName,followerListSet})
    {:noreply,state}
  end
  
  def handle_cast({:RemoveFollowerFromUser,userName,followerUserName},state) do
    [{_, followerListSet}]= :ets.lookup(:followerMap, userName)
    MapSet.delete(followerListSet, followerUserName)
    :ets.insert(:followerMap, {userName,followerListSet})
    {:noreply,state}
  end

  def handle_call({:GetFollowerList,userName},_from,state) do
    #[{_, followerListSet}]= :ets.lookup(:followerMap, userName)
    list= :ets.lookup(:followerMap, userName)
    resultList=[]
    if length(list) !=0 do
      [{_, followerListSet}]=list      
      resultList=MapSet.to_list(followerListSet)
    end
    {:reply,resultList,state}
  end

end
