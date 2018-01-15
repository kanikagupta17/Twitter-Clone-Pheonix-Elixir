defmodule ReTweetService do
    use GenServer

    def startReTweetService() do
        IO.puts "starting retweet service"
        {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :reTweetService) 
        :timer.sleep(50); 
        reTweetService()
    end 
  

    def reTweetService()  do
        Enum.each([2,3,6,12,25,50],fn(category)-> 
            GenServer.cast(:reTweetService, {:reTweetService,category})
        end)
        #:timer.sleep(500)
        #Sleep
        reTweetService()
    end

    def handle_cast({:reTweetService,category},state) do
        
        #IO.puts "retweet service im up"
        cond do
            (category==2) ->
                [{_, retweetFreq}] = :ets.lookup(:cat2Table, "retweetFreq")
                :timer.sleep(retweetFreq)
                ##Sleep(followfeq)
                retweet(category)
      
            (category==3) ->
                [{_, retweetFreq}] = :ets.lookup(:cat3Table, "retweetFreq")
                :timer.sleep(retweetFreq)
                 ##Sleep(followfeq)
                retweet(category)

            (category==6) ->
                [{_, retweetFreq}] = :ets.lookup(:cat6Table, "retweetFreq")
                :timer.sleep(retweetFreq);
                ##Sleep(followfeq)
                retweet(category)

            (category==12) ->
                [{_, retweetFreq}] = :ets.lookup(:cat12Table, "retweetFreq")
                :timer.sleep(retweetFreq)
                ##Sleep(followfeq)
                retweet(category)

            (category==25) ->
                [{_, retweetFreq}] = :ets.lookup(:cat25Table, "retweetFreq")
                :timer.sleep(retweetFreq)
                ##Sleep(followfeq)
                retweet(category)
                (category==50) ->
                [{_, retweetFreq}] = :ets.lookup(:cat50Table, "retweetFreq")
                :timer.sleep(retweetFreq)
                ##Sleep(followfeq)
                retweet(category)
            true->true

        end
        {:noreply,state}
    end

    def retweet(category) do
        #[{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        [{_, userCount}] = :ets.lookup(:userCounterTable, "userCounter")
        [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        sourceUserID = 
            Enum.chunk_every( category - 1..userCount , category,100)
            |>Enum.flat_map(fn(x) -> x end)
            |>Enum.random()
        sourceOffline = MapSet.member?(offlineUserSet,sourceUserID)  
        #IO.inspect offlineUserSet
        #sourceOffline = GenServer.call(:liveConn, {:checkOffline,sourceUserID})
        if sourceOffline == false do
            ##check iff online and process exists
            sourceUserName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(sourceUserID)
            nodeAtom = String.to_atom(sourceUserName)
            #IO.puts nodeAtom
            #IO.puts "Im retweeting "<> sourceUserName
            if Process.whereis(nodeAtom) !=nil do
                Process.send(nodeAtom, {:ReTweet, sourceUserName},[:noconnect])
            end
           
            #GenServer.cast(nodeAtom, {:ReTweet, sourceUserName})
            #IO.puts "Retweeted"
        end
        
    end

  

end