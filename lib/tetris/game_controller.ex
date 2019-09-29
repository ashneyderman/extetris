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
            timer_ref: nil,
            state_change_listener: nil

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
    state_change_listener = Keyword.get(opts, :state_change_listener)

    timer_ref =
      if start_timer do
        :erlang.send_after(timer_interval(level), self(), :tick)
      else
        nil
      end

    {:ok, new_field} = Field.new(width, height)
    next_shape = ShapeRepository.select_random_shape()

    init_state = %GameController{
      field: new_field,
      current_shape: next_shape,
      current_shape_coord: [div(width - 1, 2), Shape.pick_starting_y_coord(next_shape)],
      timer_ref: timer_ref,
      game_state: :running,
      level: level,
      state_change_listener: state_change_listener
    }

    notify_of_change(%GameController{}, init_state)

    {:ok, init_state}
  end

  def handle_call(:get_game_state, _from, %GameController{game_state: game_state} = state) do
    {:reply, game_state, state}
  end

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
    next_state =
      if Field.can_move?(field, shape, shape_x, shape_y + 1) do
        move_shape_down(state)
      else
        if shape_y <= Shape.pick_starting_y_coord(shape) do
          %GameController{state | game_state: :over}
        else
          flip_to_next_shape(state)
        end
      end

    notify_of_change(state, next_state)

    if next_state.game_state != :over do
      {:noreply, next_state}
    else
      {:stop, :normal, %GameController{}}
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

    next_state =
      if Field.can_move?(field, rotated, shape_x, shape_y) do
        %GameController{state | current_shape: rotated}
      else
        state
      end

    notify_of_change(state, next_state)

    {:noreply, next_state}
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

    next_state =
      if Field.can_move?(field, rotated, shape_x, shape_y) do
        %GameController{state | current_shape: rotated}
      else
        state
      end

    notify_of_change(state, next_state)

    {:noreply, next_state}
  end

  def handle_info(
        {:key_press, :left},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    next_state =
      if Field.can_move?(field, current_shape, shape_x - 1, shape_y) do
        %GameController{state | current_shape_coord: [shape_x - 1, shape_y]}
      else
        state
      end

    notify_of_change(state, next_state)

    {:noreply, next_state}
  end

  def handle_info(
        {:key_press, :right},
        %GameController{
          field: field,
          current_shape: current_shape,
          current_shape_coord: [shape_x, shape_y]
        } = state
      ) do
    next_state =
      if Field.can_move?(field, current_shape, shape_x + 1, shape_y) do
        %GameController{state | current_shape_coord: [shape_x + 1, shape_y]}
      else
        state
      end

    notify_of_change(state, next_state)

    {:noreply, next_state}
  end

  def handle_info(
        {:key_press, :toggle_state},
        %GameController{
          timer_ref: timer_ref,
          game_state: :running
        } = state
      ) do
    :erlang.cancel_timer(timer_ref)
    next_state = %GameController{state | timer_ref: nil, game_state: :paused}
    notify_of_change(state, next_state)
    {:noreply, next_state}
  end

  def handle_info(
        {:key_press, :toggle_state},
        %GameController{game_state: :paused, level: level} = state
      ) do
    timer_ref = :erlang.send_after(timer_interval(level), self(), :tick)
    next_state = %GameController{state | timer_ref: timer_ref, game_state: :running}
    notify_of_change(state, next_state)
    {:noreply, next_state}
  end

  def handle_info(msg, state) do
    {:noreply, state}
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

  defp notify_of_change(%GameController{} = state, %GameController{state_change_listener: state_change_listener} = next_state) do
    map_state = Map.from_struct(state) |> Map.drop([:timer_ref, :state_listener])
    map_next_state = Map.from_struct(next_state) |> Map.drop([:timer_ref, :state_listener])
    if state_change_listener != nil && map_state != map_next_state do
      Process.send(state_change_listener, {:state_change, map_next_state}, [])
    end
    :ok
  end

  defp timer_interval(level) do
    50 * (1 + level)
  end
end
