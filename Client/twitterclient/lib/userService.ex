defmodule UserService do
  use GenServer

  def startNewUserService() do
    userCounterTable = :ets.new(:userCounterTable, [:named_table,:public])
    :ets.insert(:userCounterTable, {"userCounter",0})
    #:ets.insert(:userCounterTable, {"serverNode",serverNode})
    #:ets.insert(:userCounterTable, {"clientNode",clientNode})
    startCat2UserBucket()
    startCat3UserBucket()
    startCat6UserBucket()
    startCat12UserBucket()
    startCat25UserBucket()
    startCat50UserBucket()
    
    #LiveConnection.startConnectionService()
    Task.start(LiveConnection,:startConnectionService,[])

   
    Task.start(FollowService,:startFollowService,[])
   
    Task.start(TweetService,:startTweetService,[])
    
    Task.start(ReTweetService,:startReTweetService,[])
    
    Task.start(UserService,:newUserJoins,[])
   
  end

  

  def newUserJoins() do #HANDLECast
    #IO.puts "Starting new user service"
    #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
    [{_, userIdOld}] = :ets.lookup(:userCounterTable, "userCounter")
    userIdNew = :ets.update_counter(:userCounterTable, "userCounter", {2,100})
    IO.puts "userCount = "<> Integer.to_string(userIdNew)
    Enum.each(userIdOld + 1..userIdNew, fn(x) ->
      userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(x)
      userAtom = String.to_atom(userName)
      #IO.puts "Registering username = "<>userName
      #GenServer.cast({:worker, serverNode}, {:RegisterNewUser, userName, Atom.to_string(Node.self) <>  Integer.to_string(x) ,  Integer.to_string(x)})
      #IO.puts "logging IN while registering username = "<>userName                 #{userName, fullname,pass}           
      #GenServer.call({:worker, serverNode}, {:LoginRequest, userName, Integer.to_string(x)})
      
      startUser(userAtom)                                   #{userName, pass}
      #password = Integer.to_string(x)
      registerClient(userName,x)

      loginClient(userName,x)

      #creating user Room
      Process.send(userAtom, {:join, "user:"<>userName,userName},[])

    end) 
    ##sleep()
    :timer.sleep(4000)
    newUserJoins()
  end

  def registerClient(userName,userNumber) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:join, "user:register"},[])
    Process.send(userAtom, {:user_details, userNumber},[])

    #GenSocketClient.join(transport, "user:register")
    #GenSocketClient.push(transport, "user:register", "user_details", %{"userName" => "nikhil60", "fullName" => "Nikhil Chopra", "password" => "12345"})
    
  end

  def loginClient(userName,userNumber) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:user_login, userName,userNumber},[])
  end
 
  def startCat2UserBucket() do
    cat2Table = :ets.new(:cat2Table, [:named_table,:public])
    :ets.insert(:cat2Table, {"followFreq",0})
    :ets.insert(:cat2Table, {"tweetFreq",50})
    :ets.insert(:cat2Table, {"retweetFreq",70})
  end


  def startCat3UserBucket() do
    cat3Table = :ets.new(:cat3Table, [:named_table,:public])
    :ets.insert(:cat3Table, {"followFreq",3})
    :ets.insert(:cat3Table, {"tweetFreq",80})
    :ets.insert(:cat3Table, {"retweetFreq",100})   
  end

  def startCat6UserBucket() do
    cat6Table = :ets.new(:cat6Table, [:named_table,:public])
    :ets.insert(:cat6Table, {"followFreq",6})
    :ets.insert(:cat6Table, {"tweetFreq",160})
    :ets.insert(:cat6Table, {"retweetFreq",200})   
  end

  def startCat12UserBucket() do
    cat12Table = :ets.new(:cat12Table, [:named_table,:public])
    :ets.insert(:cat12Table, {"followFreq",12})
    :ets.insert(:cat12Table, {"tweetFreq",300})
    :ets.insert(:cat12Table, {"retweetFreq",400})   
  end

  def startCat25UserBucket() do
    cat25Table = :ets.new(:cat25Table, [:named_table,:public])
    :ets.insert(:cat25Table, {"followFreq",24})
    :ets.insert(:cat25Table, {"tweetFreq",400})
    :ets.insert(:cat25Table, {"retweetFreq",500})   
  end

  def startCat50UserBucket() do
    cat50Table = :ets.new(:cat50Table, [:named_table,:public])
    :ets.insert(:cat50Table, {"followFreq",35})
    :ets.insert(:cat50Table, {"tweetFreq",500})
    :ets.insert(:cat50Table, {"retweetFreq",600})   
  end

  def startUser(userAtom) do
    #IO.inspect userAtom
    {:ok,pid} = SocketClient.start_link()
    #IO.puts "registering process"
    result=Process.register(pid, userAtom)
    #IO.inspect result
    #IO.inspect userAtom
    #{:ok, pid} = GenServer.start_link(__MODULE__,{[],[]}, name: userAtom)
  end                                     #{userTimeLineList(0),newsFeedList(1)}


  def handle_cast({:sendTweetToLiveUser, tweet}, state) do
    {homeTimeLine,newsFeed} = state
    newsFeed = [tweet] ++ newsFeed
    state = {homeTimeLine,newsFeed}
    #IO.puts "Inside " <> "got live tweet, adding to my newsfeed tweet = "<> tweet
    
    #IO.inspect self()
    {:noreply, state}
  end

  def handle_cast({:ReTweet,userName},state) do
    #IO.puts "inside handlecast for 2nd retweet"
    #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
    #[{_, clientNode}] = :ets.lookup(:userCounterTable, "clientNode")
    
    if length(elem(state,1)) >0 do
      reTweet=elem(state,1)
      |>Enum.random
      ##here server node is missing

      sourceUsernodeAtom = String.to_atom(userName)

      if Process.whereis(sourceUsernodeAtom) !=nil do
        Process.send(sourceUsernodeAtom, {:tweet, userName,reTweet},[])
      end
      

      #GenServer.cast({:worker, serverNode}, {:ReTweetRequest, clientNode,userName, reTweet})
      #IO.puts "Retweeted "
      
    end
    {:noreply, state}
  end

  def handle_cast({:FlushList},state) do
    state={[],[]}
    {:noreply, state}
  end

   def handle_call({:FillList,userTimeLineTweets,newsFeedTweets},_from,state) do
    state={userTimeLineTweets,newsFeedTweets}
    {:reply, :ok,state}
  end


end