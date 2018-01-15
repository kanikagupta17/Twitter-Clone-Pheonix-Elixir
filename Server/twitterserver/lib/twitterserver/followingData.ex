defmodule FollowingData do
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
    
    followingMap = :ets.new(:followingMap, [:named_table,:public])
    {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :followings)
    
  end

  def handle_cast({:AddFollowingToUser,userName,followingUserName},state) do
    list = :ets.lookup(:followingMap, userName)
    if(length(list) == 0) do
        followingListSet = MapSet.new
    else
      followingListSet = Enum.fetch!(list,0) |> elem(1)    
    end
    
    MapSet.put(followingListSet, followingUserName)
    :ets.insert(:followingMap, {userName,followingListSet})
    {:noreply,state}
  end
  
  def handle_cast({:RemoveFollowingFromUser,userName,followingUserName},state) do
    [{_, followingListSet}]= :ets.lookup(:followingMap, userName)
    MapSet.delete(followingListSet, followingUserName)
    :ets.insert(:followingMap, {userName,followingListSet})
    {:noreply,state}
  end

  def handle_call({:GetFollowingList,userName},_from,state) do
    #[{_, followingListSet}]= :ets.lookup(:followingMap, userName)

    
    
    list= :ets.lookup(:followingMap, userName)
    resultList=[]
    if length(list) !=0 do
      [{_, followingListSet}]=list 
      resultList=MapSet.to_list(followingListSet)     
    end

    
    

    {:reply,resultList,state}
  end

end
