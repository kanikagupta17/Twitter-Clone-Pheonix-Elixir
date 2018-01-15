defmodule SocketClient do
  @moduledoc false
  require Logger
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

  def start_link() do
    {:ok, pid} = GenSocketClient.start_link(
          __MODULE__,
          Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
          "ws://localhost:4000/socket/websocket"
         #"ws://192.168.0.15:4000/socket/websocket"
         
        )
    #convert this pname to atom    
   
  end

  def init(url) do
    {:connect, url, [], {[],[],""}}
  end                 # {_userTimeLine,_newsFeed,token}

  def handle_connected(transport, state) do
    #IO.inspect transport
    #IO.inspect state
    
    #Logger.info("registering user")
    #GenSocketClient.join(transport, "user:register")
    #Logger.info("sending user Details of user")
    #GenSocketClient.push(transport, "user:register", "user_details", %{"userName" => "nikhil60", "fullName" => "Nikhil Chopra", "password" => "12345"})

    #GenSocketClient.join(transport, "user:123")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    #Logger.error("disconnected: #{inspect reason}")
    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  def handle_joined(topic, _payload, transport, state) do
    #Logger.info("joined the topic #{topic}")
    #IO.inspect transport
    
    #GenSocketClient.push(transport, "user:register", "user_details", %{"userName" => "nikhil60", "fullName" => "Nikhil Chopra", "password" => "12345"})
    
    #GenSocketClient.push(transport, "user:123", "ping", %{ping_ref: state.ping_ref})
    #GenSocketClient.push(transport, "user:123", "shout", %{ping_ref: state.ping_ref})
    #if state.first_join do
      #:timer.send_interval(:timer.seconds(1), self(), :ping_server)
    #  {:ok, %{state | first_join: false, ping_ref: 1}}
    #else
      #{:ok, %{state | ping_ref: 1}}
    #end
    {:ok,state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    #Logger.error("join error on the topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    #Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

 

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    #Logger.info("server pong ##{payload["response"]["ping_ref"]}")
    {:ok, state}
  end
  #def handle_reply(topic, _ref, payload, _transport, state) do
  #  Logger.warn("reply on topic #{topic}: #{inspect payload}")
  #  {:ok, state}
  #end

  def handle_info(:connect, _transport, state) do
    #Logger.info("connecting")
    {:connect, state}
  end

  def handle_info({:join, topic}, transport, state) do
    #Logger.info("Inside join")
    GenSocketClient.join(transport, topic)

    {:ok, state}
  end

  def handle_info({:join, topic,userName}, transport, state) do
    #Logger.info("Inside join")
    out_payload = %{"userName" => userName}
    GenSocketClient.join(transport, topic,out_payload)

    {:ok, state}
  end

  def handle_info({:follow, topic,followerName}, transport, state) do
    #Logger.info("user "<>followerName<>" adding to followergrp of "<>topic)
    #Logger.info("Sending follow request from user "<>followerName<>" to join follower group of "<>topic)
    GenSocketClient.join(transport, topic, %{"userName" => followerName})

    {:ok, state}
  end


  def handle_info({:user_details,userNumber}, transport, state) do

    

    userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber)
    fullName =  Atom.to_string(Node.self) <>  Integer.to_string(userNumber)

    #Logger.info("sending user details for registration of user: "<> userName)

    GenSocketClient.push(transport, "user:register", "user_details", %{"userName" => userName, "fullName" => fullName, "password" => Integer.to_string(userNumber)})

    {:ok, state}
  end

#for single
  def handle_info({:user_details,userName,fullName,password}, transport, state) do

    #Logger.info("sending user details for registration of user: "<> userName)

    GenSocketClient.push(transport, "user:register", "user_details", %{"userName" => userName, "fullName" => fullName, "password" => password})

    {:ok, state}
  end




  def handle_reply("user:register", _ref, payload, _transport, state) do
    #IO.inspect token
    response = Map.fetch!(payload, "response")
    token = Map.fetch!(response, "token")
    #Logger.info("Token recieved from server after user registration and storing it in the client state")
    {_userTimeLine,_newsFeed, _x } = state
    state = {_userTimeLine,_newsFeed, token }
    {:ok, state}
  end

  def handle_info({:getHashTag,hashTag}, transport, state) do
    #Logger.info("Sending search Hash Tag request")
    GenSocketClient.push(transport, "user:register", "search_hashTag", %{"hashTag" => hashTag})
    
    {:ok, state}
  end


  def handle_message("user:register", "search_hashTag", payload, _transport, state) do
    #Logger.info("Response recieved from server for search Hash Tag request")

    #response = Map.fetch!(payload, "response")
    
    hashTagTweetList = Map.fetch!(payload, "hashTagTweetList")
    IO.inspect hashTagTweetList
    {:ok, state}
  end

  def handle_info({:getUserMention,userName}, transport, state) do

    #Logger.info("Sending search User Mentions request")
    GenSocketClient.push(transport, "user:register", "search_userMention", %{"userName" => userName})
    
    {:ok, state}
  end
  
  def handle_message("user:register", "search_userMention", payload, _transport, state) do
    #Logger.info("getting reply after user login")

    #response = Map.fetch!(payload, "response")
    #Logger.info("Response recieved from server for search User Mentions request")
    mentionsTweetList = Map.fetch!(payload, "mentionsTweetList")
    IO.inspect mentionsTweetList
    {:ok, state}
  end



   #def handle_reply(topic, _ref, payload, _transport, state) do
  #  Logger.warn("reply on topic #{topic}: #{inspect payload}")
  #  {:ok, state}
  #end

  

  def handle_message("user_details", _ref, token, _transport, state) do

    #Logger.info("Token recieved from server after user registration and storing it in the client state")
    {_userTimeLine,_newsFeed, _x } = state
    state = {_userTimeLine,_newsFeed, token }
    {:ok, state}
  end

  def handle_info({:user_login, userName,userNumber}, transport, state) do
    userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber)
    
    #Logger.info("login user: "<> userName)
    {_x,_y, token } = state
    GenSocketClient.push(transport, "user:register", "login", %{"userName" => userName, "password" => Integer.to_string(userNumber), "token" => token})

    {:ok, state}
  end

  #for single
  def handle_info({:user_login_pass, userName,password}, transport, state) do
    #userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber)
    
    #Logger.info("Sending login request for user: "<> userName)
    {_x,_y, token } = state
    GenSocketClient.push(transport, "user:register", "login", %{"userName" => userName, "password" => password, "token" => token})

    {:ok, state}
  end

  

  
  def handle_info({:user_logout, userName}, transport, state) do
    #userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber)
    
    #Logger.info("logout user: "<> userName)

    GenSocketClient.push(transport, "user:register", "logout",  %{"userName" => userName})

    {:ok, state}
  end

  def handle_reply("login", _ref, payload, _transport, state) do

    #Logger.info("getting reply after user login")
    #Logger.info("Token recieved from server after user registration and storing it in the client state")
    {_x,_y, _token } = state
    {userTimeLineTweets, newsFeedTweets } = payload
    state = {userTimeLineTweets, newsFeedTweets , _token }
    {:ok, state}
  end

  def handle_message("user:register", "login", payload, _transport, state) do
    #Logger.info("getting reply after user login")

    #response = Map.fetch!(payload, "response")
    if Map.has_key?(payload,"reason") do
      Logger.warn("User Unauthorized") 
    
    else
      #Logger.info("User Successfully logged in")
      userTimeLineTweets = Map.fetch!(payload, "userTimeLineTweets")
      newsFeedTweets = Map.fetch!(payload, "newsFeedTweets")
      
  
      {_x,_y, _token } = state
      
      state = {userTimeLineTweets, newsFeedTweets , _token }
    end    
    
    {:ok, state}
  end


  def handle_info({:tweet, userName, tweet}, transport, state) do
    

    #Logger.info("Sending tweet request from user: "<> userName)

    GenSocketClient.push(transport, "user:"<>userName, "tweet",  %{"tweet" => tweet,"userName" => userName} )

    {:ok, state}
  end


  def handle_message(topic, "tweet", payload, _transport, state) do
    #Logger.info("getting tweet from broadcast")

    #response = Map.fetch!(payload, "response")
    
    tweet = Map.fetch!(payload, "tweet")
    #Logger.info("Tweet Received: "<> tweet)
    {_homeTimeLine,newsFeed,_token} = state
    newsFeed = newsFeed ++ [tweet]

    state = {_homeTimeLine,newsFeed, _token }
    
    #state = {userTimeLineTweets, newsFeedTweets , _token }
    {:ok, state}
  end

  


  def handle_reply("tweet", _ref, payload, _transport, state) do

    #Logger.info("getting reply for himself after teet")
    tweet = Map.fetch!(payload, "tweet")
    ##need to correct the logic
    {homeTimeLine,newsFeed} = state
    newsFeed = [tweet] ++ newsFeed
    state = {homeTimeLine,newsFeed}
    
    #state = {_,_, token }
    {:ok, state}
  end

  def handle_info({:ReTweet, userName}, transport, state) do
  #def handle_cast({:ReTweet,userName},state) do
    #IO.puts "inside handlecast for 2nd retweet"
    #[{_, serverNode}] = :ets.lookup(:userCounterTable, "serverNode")
    #[{_, clientNode}] = :ets.lookup(:userCounterTable, "clientNode")
    #Logger.info("ReTweeting user: "<> userName)

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
    #{:noreply, state}
    {:ok, state}
  end

  def handle_info({:FlushList, userName}, transport, state) do

    {_homeTimeLine,_newsFeed,_token} = state
    state={[], [], _token}

    {:ok, state}
  end





  def handle_info(:ping_server, transport, state) do
    #Logger.info("sending ping ##{state.ping_ref}")
    GenSocketClient.push(transport, "ping", "ping", %{ping_ref: state.ping_ref})
    {:ok, %{state | ping_ref: state.ping_ref + 1}}
  end
  def handle_info(message, _transport, state) do
    #Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    #Logger.warn("message on topic #{topic}: #{event} #{inspect payload}")
    {:ok, state}
  end
end