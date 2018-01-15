defmodule Twitterclient do
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
  def main(args) do

    #serverIP=Enum.at(args, 0)
    #{serverNode,clientNode}=setup_client(serverIP)
    setup_client()
    UserService.startNewUserService()
    #SocketClient.start_link()
    #mainGenSoc()
    infiniteLoop()
  end

  def register(userName,fullName,password) do
    userAtom = String.to_atom(userName)
    {:ok,pid} = SocketClient.start_link()
    :timer.sleep(100)
    result=Process.register(pid, userAtom)                                  #{userName, pass}
    Process.send(userAtom, {:join, "user:register"},[])
    :timer.sleep(200)
    Process.send(userAtom, {:user_details, userName,fullName,password},[])
    :timer.sleep(200)
    Process.send(userAtom, {:join, "user:"<>userName,userName},[])
    #:timer.sleep(50)


  end

  def login(userName,password) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:user_login_pass, userName,password},[])
  end

  def tweet(userName,tweet) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:tweet, userName,tweet},[])
  end

  def follow(userName,followUserName) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:follow, "user:"<>followUserName,userName},[])
  end

  def getUserMention(userName) do
    
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:getUserMention, userName},[])
  end

  def getHashTag(userName,hashTag) do
    userAtom = String.to_atom(userName)
    Process.send(userAtom, {:getHashTag, hashTag},[])
        
  end
  
  def mainGenSoc() do

    #userNumber1=1
    #userName1 = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber1)
    #userAtom1 = String.to_atom(userName1)

   # UserService.startUser(userAtom1)                                   #{userName, pass}

    #UserService.registerClient(userName1,userNumber1)

    #UserService.loginClient(userName1,userNumber1)

      #creating user Room
    #Process.send(userAtom1, {:join, "user:"<>userName1,userName1},[])

    #Process.send(userAtom1, {:tweet, userName1,"hello gudbye"},[])


    #userNumber2=2
    #userName2 = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(userNumber2)
    #userAtom2 = String.to_atom(userName2)

    #UserService.startUser(userAtom2)                                   #{userName, pass}

    #UserService.registerClient(userName2,userNumber2)

    #UserService.loginClient(userName2,userNumber2)

      #creating user Room
    #Process.send(userAtom2, {:join, "user:"<>userName2,userName2},[])
    #user 1
    {:ok, userAtom}=SocketClient.start_link
    :timer.sleep(50)
    Process.send(userAtom, {:join, "user:register"},[])
    :timer.sleep(50)
    Process.send(userAtom, {:user_details,  1},[])
    :timer.sleep(50)
    userName = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(1)
    Process.send(userAtom, {:user_login, userName,1},[])

    Process.send(userAtom, {:follow, "user:"<>userName,userName},[])


    #user 2
    {:ok, userAtom2}=SocketClient.start_link
    :timer.sleep(50)
    Process.send(userAtom2, {:join, "user:register"},[])
    :timer.sleep(50)
    Process.send(userAtom2, {:user_details,  2},[])
    :timer.sleep(50)
    userName2 = Atom.to_string(Node.self) <> ":USER:" <>  Integer.to_string(2)
    Process.send(userAtom2, {:user_login, userName,2},[])

    :timer.sleep(150)
    Process.send(userAtom2, {:follow, "user:"<>userName,userName2},[])
    
    :timer.sleep(150)
    Process.send(userAtom, {:tweet, userName,"hello gudbye"},[])

    Process.send(userAtom, {:tweet, userName,"hello gudbye #myTwitter"},[])
    Process.send(userAtom, {:tweet, userName,"hello gudbye @"<>userName2},[])


    :timer.sleep(350)
    Process.send(userAtom2, {:ReTweet, userName2},[])
    
    hashTag = "#myTwitter"
    Process.send(userAtom, {:getHashTag, hashTag},[])
    
    Process.send(userAtom2, {:getUserMention, userName2},[])
    
    IO.puts "sending logout"
    
    
    
    :timer.sleep(150)
    #Process.send(userAtom, {:user_logout, userName},[])
    IO.puts "sending logout"
    :timer.sleep(150)
    #Process.send(userAtom2, {:user_logout, userName2},[])
    

  end

  def mainM() do
    {:ok, pid} = PhoenixChannelClient.start_link()
    #register pid with name of client(1..numofClients)
    
    {:ok, socket} = PhoenixChannelClient.connect(pid,
      host: "localhost",
      path: "/socket/websocket",
      params: %{token: "something"},
      secure: false)
    
    #channel = PhoenixChannelClient.channel(socket, "room:"<>clientName, %{name: clientName})
    channel = PhoenixChannelClient.channel(socket, "room:public", %{name: "Ryo"})
    
    case PhoenixChannelClient.join(channel) do
      {:ok, %{message: message}} -> IO.puts(message)
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout -> IO.puts("timeout")
    end
    
    case PhoenixChannelClient.push_and_receive(channel, "search", %{query: "Elixir"}, 100) do
      {:ok, %{result: result}} -> IO.puts("#\{length(result)} items")
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout -> IO.puts("timeout")
    end
    
    receive do
      {"new_msg", message} -> IO.puts(message)
      :close -> IO.puts("closed")
      {:error, error} -> ()
    end
    
    :ok = PhoenixChannelClient.leave(channel)
  end

  def maingen() do
    #GenSocketClient.
  end



  def mainMethod(serverNode,clientNode) do
    
        {:ok, pid} = GenServer.start_link(__MODULE__,{[],[]}, name: :"first")
        {:ok, pid1} = GenServer.start_link(__MODULE__,{[],[]}, name: :"second")
        {:ok, pid1} = GenServer.start_link(__MODULE__,{[],[]}, name: :"third")
    
        IO.puts "Inside Twitter Cclient"
        GenServer.cast({:worker, serverNode}, {:RegisterNewUser, "first", "Kanika Gupta", "Kani"})
        IO.puts "first user registerd"
        GenServer.cast({:worker, serverNode}, {:RegisterNewUser, "second", "Nikhil Chopra", "Nikku"})
        IO.puts "second user registeredd"
    
        GenServer.cast({:worker, serverNode}, {:RegisterNewUser, "third", "Nik Chops", "nakes"})
        IO.puts "third user registeredd"
    
        GenServer.call({:worker, serverNode}, {:LoginRequest, "first"})
        IO.puts "logined first user"
    
        GenServer.call({:worker, serverNode}, {:LoginRequest, "second"})
        IO.puts "logdedd in second user"
        
        GenServer.call({:worker, serverNode}, {:LoginRequest, "third"})
        IO.puts "logdedd in third user"
    
    
        GenServer.cast({:worker, serverNode}, {:FollowRequest, "second", "first"})
        Process.sleep(1000)
        IO.puts "followed"
    
        GenServer.cast({:worker, serverNode}, {:FollowRequest, "third", "second"})
        Process.sleep(1000)
        IO.puts "followed"
        
        #GenServer.cast(:worker, {:TweetRequest, "first", "I am new to twitter. It sucks"})
        #IO.puts "tweeted"
    
        GenServer.cast({:worker, serverNode}, {:TweetRequest, clientNode,"first", "hello @third gudbye"})
        IO.puts "tweeted with mentioned"
    
    
        GenServer.cast({:worker, serverNode}, {:ReTweetRequest, clientNode,"second", "hello @third gudbye"})
        IO.puts "Retweeted "
    
        #mentionList=GenServer.call(:worker, {:GetMentions,"third"})
        #IO.puts "getting mentions"
        #IO.inspect mentionList
    
    
        #GenServer.cast(:worker, {:TweetRequest, "first", "hello #hellobro gudbye"})
        #IO.puts "tweeted with hashtags"
    
        #hashTagList=GenServer.call(:worker, {:GetHashTags,"#hellobro"})
        #IO.puts "getting hashtags"
        #IO.inspect hashTagList
        
        infiniteLoop()
      end
    
  



  def setup_client() do 
    unless Node.alive?() do
      local_node_name = generate_name_client("client")
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env("server", :cookie)
    #Node.set_cookie(:"Server-cookie")
    #serverNode=String.to_atom("server@#{input}")
    #Node.connect(serverNode)
    #IO.puts "Client connected to Server IP #{input}"
    #{serverNode,local_node_name}
  end 

  def generate_name_client(appname) do
    {:ok,host}= :inet.gethostname
    {:ok,{a,b,c,d}} = :inet.getaddr(host, :inet)
    if a==127 do 
      {:ok, list_ips} = :inet.getif()
      ip=list_ips
      |> Enum.at(0) 
      |> elem(0) 
      |> :inet_parse.ntoa 
      |> IO.iodata_to_binary
    else
      ip=Integer.to_string(a)<>"."<>Integer.to_string(b)<>"."<>Integer.to_string(c)<>"."<>Integer.to_string(d)
    end
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    IO.puts "Client started with IP Address: #{ip}"  
    #String.to_atom("#{appname}-#{hex}@#{machine}")
    String.to_atom("#{appname}-#{hex}@#{ip}")
  end


  def infiniteLoop() do
    infiniteLoop()
  end

end
