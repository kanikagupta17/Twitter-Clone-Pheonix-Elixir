defmodule TweetService do
    use GenServer
    
    def startTweetService() do
        IO.puts "starting tweet service"
        
        {:ok, pid} = GenServer.start_link(__MODULE__,[], name: :tweetService)  
        :timer.sleep(50)
        tweetService()
    end

    def tweetService()  do
        Enum.each([2,3,6,12,25,50],fn(category)-> 
            GenServer.cast(:tweetService, {:tweetService,category})
        end)
        #:timer.sleep(500)
        #Sleep
        tweetService()
    end

    def handle_cast({:tweetService,category},state) do
        
        #IO.puts "tweet service im up"
        cond do
            (category==2) ->
                [{_, tweetFreq}] = :ets.lookup(:cat2Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)
      
            (category==3) ->
                [{_, tweetFreq}] = :ets.lookup(:cat3Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)

            (category==6) ->
                [{_, tweetFreq}] = :ets.lookup(:cat6Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)

            (category==12) ->
                [{_, tweetFreq}] = :ets.lookup(:cat12Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)

            (category==25) ->
                [{_, tweetFreq}] = :ets.lookup(:cat25Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)
            (category==50) ->
                [{_, tweetFreq}] = :ets.lookup(:cat50Table, "tweetFreq")
                :timer.sleep(tweetFreq)
                ##Sleep(followfeq)
                tweet(category)
            true->true

        end
        {:noreply,state}
    end
    
    def tweet(category) do
        #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
        [{_, userCount}] = :ets.lookup(:userCounterTable, "userCounter")
        #[{_, clientNode}] = :ets.lookup(:userCounterTable, "clientNode")
        [{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        #[{_, offlineUserSet}] = :ets.lookup(:liveConnTable, "offlineUserSet")
        sourceUserID = 
            Enum.chunk_every( category - 1..userCount , category,100)
            |>Enum.flat_map(fn(x) -> x end)
            |>Enum.random()

        sourceOffline = MapSet.member?(offlineUserSet,sourceUserID)
        #sourceOffline = GenServer.call(:liveConn, {:checkOffline,sourceUserID})    
        if sourceOffline == false do
            ##check iff online and process exists
            sourceUserName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(sourceUserID)
            #IO.puts "Im retweeting "<> sourceUserName
            ## generate random string ##serverNode is missing

            sourceUsernodeAtom = String.to_atom(sourceUserName)

            if Process.whereis(sourceUsernodeAtom) !=nil do
                Process.send(sourceUsernodeAtom, {:tweet, sourceUserName,"hello gudbye"},[])
            end

            

            #GenServer.cast({:worker, serverNode}, {:TweetRequest, clientNode,sourceUserName, "hello gudbye"})
            #IO.puts "restweeted"
        end
    end


end