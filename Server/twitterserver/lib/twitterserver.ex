defmodule Twitterserver do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Twitterserver.Endpoint, []),
      # Start your own worker by calling: Twitterserver.Worker.start_link(arg1, arg2, arg3)
      # worker(Twitterserver.Worker, [arg1, arg2, arg3]),
      supervisor(Twitterserver.Presence, []),
      worker(UserData, [[name: UserData]]),
      worker(FollowerData, [[name: FollowerData]]),
      worker(FollowingData, [[name: FollowingData]]),
      worker(Tweets, [[name: Tweets]]),
      worker(UserTimeLineData, [[name: UserTimeLineData]]),
      worker(NewsFeedData, [[name: NewsFeedData]]),
      worker(ActiveUserData, [[name: ActiveUserData]]),
      worker(UserMentionsData, [[name: UserMentionsData]]),
      worker(HashTagData, [[name: HashTagData]])
      #worker(StatsService, [[name: StatsService]]),


    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Twitterserver.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Twitterserver.Endpoint.config_change(changed, removed)
    :ok
  end
end
