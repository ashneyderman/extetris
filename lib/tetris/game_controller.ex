defmodule Tetris.GameController do
  use GenServer

  @moduledoc """
  This module is the game controller.
  """

  alias Tetris.{Field, GameController, Shape, ShapeRepository}

  @type game_state :: :paused | :running | :over
  @type key_event :: :esc | :space | :left | :right | :rotate_cw | :rotate_ccw

  defstruct field: [],
            current_shape: nil,
            current_shape_coord: [4, -3],
            score: 0,
            game_state: :paused,
            level: 0,
            timer_ref: nil

  def start_link(args) do
    # IO.puts("start_link(args): #{inspect(args, pretty: true)}")
    # GenServer.start_link(__MODULE__, args, [debug: [:trace]])
    GenServer.start_link(__MODULE__, args)
  end

  def game_state(pid) do
    GenServer.call(pid, :get_game_state)
  end

  def init(opts) do
    level = Keyword.get(opts, :level, 5)
    width = Keyword.get(opts, :width, 10)
    height = Keyword.get(opts, :height, 18)
    start_timer = Keyword.get(opts, :start_timer, true)

    timer_ref =
      if start_timer do
        :erlang.send_after(timer_interval(level), self(), :tick)
      else
        nil
      end

    {:ok, new_field} = Field.new(width, height)
    next_shape = ShapeRepository.select_random_shape()

    {:ok,
     %GameController{
       field: new_field,
       current_shape: next_shape,
       current_shape_coord: [div(width - 1, 2), Shape.pick_starting_y_coord(next_shape)],
       timer_ref: timer_ref,
       game_state: :running,
       level: level
     }}
  end

  def handle_call(:get_game_state, _from, %GameController{game_state: game_state} = state) do
    {:reply, game_state, state}
  end

  @doc """
  Pauses the game.
  """
  def handle_info(:pause, %GameController{} = state) do
    {:noreply, state}
  end

  @doc """
  Restarts the game.
  """
  def handle_info(:restart, %GameController{} = state) do
    {:noreply, state}
  end

  # Field.capture(field, shape, shape_x, shape_y)
  # |> elem(1)
  # |> Field.pp
  @doc """
  Moves the state of the game forward due to a periodic time event.
  """
  def handle_info(
        :tick,
        %GameController{
          field: field,
          current_shape: shape,
          current_shape_coord: [shape_x, shape_y],
          game_state: :running
        } = state
      ) do
    if Field.can_move?(field, shape, shape_x, shape_y + 1) do
      {:noreply, move_shape_down(state)}
    else
      if shape_y <= Shape.pick_starting_y_coord(shape) do
        {:noreply, %GameController{state | game_state: :over}}
      else
        {:noreply, flip_to_next_shape(state)}
      end
    end
  end

  def handle_info(:tick, %GameController{} = state) do
    {:noreply, state}
  end

  def handle_info(
        {:key_press, :rotate_ccw},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    rotated = Shape.rotate(current_shape, :ccw)

    if Field.can_move?(field, rotated, shape_x, shape_y) do
      {:noreply, %GameController{state | current_shape: rotated}}
    else
      {:noreply, state}
    end
  end

  def handle_info(
        {:key_press, :rotate_cw},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    rotated = Shape.rotate(current_shape, :cw)

    if Field.can_move?(field, rotated, shape_x, shape_y) do
      {:noreply, %GameController{state | current_shape: rotated}}
    else
      {:noreply, state}
    end
  end

  def handle_info(
        {:key_press, :left},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    if Field.can_move?(field, current_shape, shape_x - 1, shape_y) do
      {:noreply, %GameController{state | current_shape_coord: [shape_x - 1, shape_y]}}
    else
      {:noreply, state}
    end
  end

  def handle_info(
        {:key_press, :right},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    if Field.can_move?(field, current_shape, shape_x + 1, shape_y) do
      {:noreply, %GameController{state | current_shape_coord: [shape_x + 1, shape_y]}}
    else
      {:noreply, state}
    end
  end

  def handle_info(
        {:key_press, :pause},
        %GameController{
          timer_ref: timer_ref,
          game_state: :running
        } = state
      ) do
    :erlang.cancel_timer(timer_ref)
    {:noreply, %GameController{state | timer_ref: nil, game_state: :paused}}
  end

  def handle_info(
        {:key_press, :restart},
        %GameController{game_state: :paused, level: level} = state
      ) do
    timer_ref = :erlang.send_after(timer_interval(level), self(), :tick)
    {:noreply, %GameController{state | timer_ref: timer_ref, game_state: :running}}
  end

  # Helpers
  defp move_shape_down(
         %GameController{current_shape_coord: [shape_x, shape_y], level: level} = state
       ) do
    timer_ref = :erlang.send_after(timer_interval(level), self(), :tick)

    %GameController{
      state
      | timer_ref: timer_ref,
        current_shape_coord: [shape_x, shape_y + 1]
    }
  end

  defp flip_to_next_shape(
         %GameController{
           field: field,
           current_shape: shape,
           current_shape_coord: [shape_x, shape_y],
           game_state: :running,
           score: score,
           level: level
         } = state
       ) do
    {rows_eliminated, new_field} = Field.capture(field, shape, shape_x, shape_y)

    next_shape = ShapeRepository.select_random_shape()
    timer_ref = :erlang.send_after(timer_interval(level), self(), :tick)

    score_inc = rows_eliminated * 2

    %GameController{
      state
      | field: new_field,
        timer_ref: timer_ref,
        current_shape: next_shape,
        current_shape_coord: [div(field.width - 1, 2), Shape.pick_starting_y_coord(next_shape)],
        score: score + score_inc
    }
  end

  defp timer_interval(level) do
    50 * (1 + level)
  end
end
