defmodule LiveConnection do
    use GenServer
    
    def startConnectionService() do
        IO.puts "starting connection serice"
        offlineUserSet=MapSet.new
        liveConnTable = :ets.new(:liveConnTable, [:named_table,:public])
        :ets.insert(:liveConnTable, {"offlineUserSet",offlineUserSet})
        {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :liveConn)
        #Task.start(LiveConnection,connectionService(),[])
        #spawn(LiveConnection,connectionService(),[])
        {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :liveConnService)
        :timer.sleep(50)
        connectionService()
        #IO.puts "after spawning connection serice"
    end

    def handle_cast({:connectionService},state) do
       
        [{_, userCounter}] = :ets.lookup(:userCounterTable, "userCounter")
        ##################to be FIIIEEEEEEEEEEEEEDDDDDDDDDD
        GenServer.cast(:liveConn, {:SendLogoutRequest,userCounter})
        GenServer.cast(:liveConn, {:SendLogInRequest,userCounter})
        
        {:noreply,state}
    end

    def connectionService() do
        GenServer.cast(:liveConnService, {:connectionService})
        #Sleep
        :timer.sleep(2000);
        connectionService()
    end

    def handle_cast({:SendLogoutRequest,userCounter},state) do
        #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
        count = userCounter*0.3 |>round() 

        if userCounter >0 do
            logoutUser = Enum.take_random(1..userCounter-99, count) 
            
            Enum.each(logoutUser, fn(x)-> 
            [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
            
                if  !(MapSet.member?(offlineUserSet, x)) do
                    offlineUserSet = MapSet.put(offlineUserSet, x)
                    :ets.insert(:liveConnTable, {"offlineUserSet",offlineUserSet})
                    userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(x)
                    #IO.inspect offlineUserSet
                    ## server node missing
                    #IO.puts "logging OUT this username in conn service " <> userName
                    logoutClient(userName)
                    #GenServer.cast({:worker, serverNode}, {:LogoutRequest, userName})
                    userAtom = String.to_atom(userName)
                    #GenServer.cast(userAtom, {:FlushList})
               end
            end)
        end
        {:noreply, state}
    end

    def handle_cast({:SendLogInRequest,userCounter},state) do
        #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
        count = userCounter*0.5 
            |>round()## convert to float
        [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")

        if userCounter > 0 do
            offlineUserList=
            MapSet.to_list(offlineUserSet)
            |>Enum.take_random(count)

            Enum.each(offlineUserList, fn(x)->
                [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
                offlineUserSet=MapSet.delete(offlineUserSet, x)
                :ets.insert(:liveConnTable, {"offlineUserSet",offlineUserSet})
                userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(x)
                ## server node missing
                #IO.inspect offlineUserSet
                #IO.puts "logging IN this username in conn service " <> userName
                
                loginClient(userName,x)
                #{userTimeLineTweets, newsFeedTweets} = GenServer.call({:worker, serverNode}, {:LoginRequest, userName, Integer.to_string(x)})
                #userAtom = String.to_atom(userName)
                #GenServer.call(userAtom, {:FillList,userTimeLineTweets,newsFeedTweets})
            end)
        end
        {:noreply, state}
    end

    def loginClient(userName,userNumber) do
        userAtom = String.to_atom(userName)
        #pid = Process.whereis(userAtom)
        if Process.whereis(userAtom) !=nil do
            Process.send(userAtom, {:user_login, userName,userNumber},[:noconnect])
        end
        
    end

    def logoutClient(userName) do
        userAtom = String.to_atom(userName)
        #pid = Process.whereis(userAtom)
        if Process.whereis(userAtom) !=nil do
            Process.send(userAtom, {:user_logout, userName},[:noconnect])

            Process.send(userAtom, {:FlushList, userName},[:noconnect])
        end
        
        #Process.send(userAtom, {:user_logout, userName},[:noconnect ])
    end


    def handle_call({:checkOffline,userId},_from,state) do
        [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        #IO.inspect offlineUserSet
        result = MapSet.member?(offlineUserSet,userId)
        {:reply, result,state}
    end
end