defmodule PiStreamCam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PiStreamCam.Supervisor]

    port = Application.get_env(:pi_stream_cam, :port)
    children =
      [
        # Children for all targets
        # Starts a worker by calling: PiStreamCam.Worker.start_link(arg)
        # {PiStreamCam.Worker, arg},
        Plug.Cowboy.child_spec(scheme: :http, plug: PiStreamCam.Router, port: port),
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: PiStreamCam.Worker.start_link(arg)
      # {PiStreamCam.Worker, arg},
      {Picam.FakeCamera, []}
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: PiStreamCam.Worker.start_link(arg)
      # {PiStreamCam.Worker, arg},
      {Picam.Camera, []}
    ]
  end

  def target() do
    Application.get_env(:pi_stream_cam, :target)
  end
end
