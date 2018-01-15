defmodule FollowService do
    use GenServer


    def startFollowService() do
        IO.puts "starting follow service"
        {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :followService)   
        :timer.sleep(50)
        followService()
    end

    def followService()  do
        Enum.each([2,3,6,12,25,50],fn(category)-> 
            GenServer.cast(:followService, {:followService,category})
        end)
        #:timer.sleep(500)
        #Sleep
        followService()
    end

    def handle_cast({:followService,category},state) do
        
        cond do
            (category==2) ->
                [{_, followFreq}] = :ets.lookup(:cat2Table, "followFreq")
                :timer.sleep(followFreq)
                ##Sleep(followfeq)
                follow(category)
                follow(category)
                follow(category)
                follow(category)
                follow(category)
                follow(category)
      
            (category==3) ->
                [{_, followFreq}] = :ets.lookup(:cat3Table, "followFreq")
                :timer.sleep(followFreq)
                follow(category)
                #:timer.sleep(3)
                follow(category)
                #:timer.sleep(3)
                follow(category)

            (category==6) ->
                [{_, followFreq}] = :ets.lookup(:cat6Table, "followFreq")
                ##Sleep(followfeq)
                :timer.sleep(followFreq)
                follow(category)
                #:timer.sleep(6)
                follow(category)

            (category==12) ->
                [{_, followFreq}] = :ets.lookup(:cat12Table, "followFreq")
                :timer.sleep(followFreq);
                ##Sleep(followfeq)
                follow(category)

            (category==25) ->
                [{_, followFreq}] = :ets.lookup(:cat25Table, "followFreq")
                :timer.sleep(followFreq)
                ##Sleep(followfeq)
                follow(category)
            (category==50) ->
                [{_, followFreq}] = :ets.lookup(:cat50Table, "followFreq")
                :timer.sleep(followFreq)
                ##Sleep(followfeq)
                follow(category)
            true->true

        end
        {:noreply,state}
    end
   
    def follow(category) do
        #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
        [{_, userCount}] = :ets.lookup(:userCounterTable, "userCounter")
        [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        #[{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")

        ##check iff online and process exists
        sourceUserID = Enum.random(1..userCount)
        ##check iff online and process exists
        destUserID = 
            Enum.chunk_every( category - 1..userCount , category,100)
            |>Enum.flat_map(fn(x) -> x end)
            |>Enum.random()
        #result = MapSet.member?(offlineUserSet,userId)
        #sourceOffline = GenServer.call(:liveConn, {:checkOffline,sourceUserID})
        #destOffline = GenServer.call(:liveConn, {:checkOffline,destUserID})
        sourceOffline = MapSet.member?(offlineUserSet,sourceUserID)
        destOffline = MapSet.member?(offlineUserSet,destUserID)
        if sourceOffline==false  && destOffline==false do 
            #IO.puts Integer.to_string(sourceUserID)<>" user is following "<> Integer.to_string(destUserID)
            sourceUserName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(sourceUserID)
            destUserName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(destUserID)
            sourceUsernodeAtom = String.to_atom(sourceUserName)
            ##serverNode is missing
            if Process.whereis(sourceUsernodeAtom) !=nil do
                Process.send(sourceUsernodeAtom, {:follow, "user:"<>destUserName,sourceUserName},[:noconnect])
            end
            
            #GenServer.cast({:worker, serverNode}, {:FollowRequest, sourceUserName, destUserName}) 
                
        end
    end



end