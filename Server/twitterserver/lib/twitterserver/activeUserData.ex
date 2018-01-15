defmodule ActiveUserData do
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
    
     activeUsersTable = :ets.new(:activeUsersTable, [:named_table,:public])
     {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :activeUsers)
    
  end

  def handle_call({:incomingActiveUser, userName}, _from, state) do 
    :ets.insert(:activeUsersTable, {userName})
    {:reply, :ok, state}
  end

  def handle_cast({:outGoingActiveUser,userName},state) do
    :ets.delete(:activeUsersTable, userName)
    {:noreply,state}
  end



  def handle_call({:checkIfActive,userName}, _from, state) do 
    list = :ets.lookup(:activeUsersTable, userName)
    result=false
    if length(list) == 1 do
      result=true
    end 
    {:reply, result, state}
  end

end
