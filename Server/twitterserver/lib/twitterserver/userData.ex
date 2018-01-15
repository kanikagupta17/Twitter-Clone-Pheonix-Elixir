defmodule UserData do
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
      
       usersTable = :ets.new(:usersTable, [:named_table,:public])
       {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :users)
      
    end

    
  
    def handle_call({:registerNewUser, userName, password, fullName}, _from, state) do 
       IO.puts "adding new user" 
      :ets.insert(:usersTable, {userName, password, fullName})
      {:reply, userName, state}
    end
  
    def handle_call({:authenticateUser, userName, password}, _from, state) do
      
      list =:ets.lookup(:usersTable, userName)
      result = ""
      cond do
        length(list) == 0 ->
          result = "Invalid User"
  
        (Enum.fetch!(list,0) |> elem(1) != password) ->
          result = "Authentication Problem"
        
        true ->
          result = "Valid User"  
      end  
        
      {:reply, result, state}
    end
  
  end
  