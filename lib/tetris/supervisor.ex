defmodule Tetris.Supervisor do
  @moduledoc false

  def start_link do
    :random.seed(:erlang.now())

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Tetris.GameControllerSup}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
