defmodule Tetris do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # :application.start(:cecho)
    Tetris.Supervisor.start_link()
  end

  #   @doc """
  #   """
  #   Record.defrecord Point, x: 0.0, y: 0.0 do
  #     def next_row(this) do
  #       Point.new().x(this.x).y(this.y + 1)
  #     end

  #     def next_col(this) do
  #       Point.new().x(this.x + 1).y(this.y)
  #     end
  #   end

  #   @doc """
  #   Shape record store the dot matrix of the shape, rotation point and color.
  #   It also provides methods to rotate the shape. A typical shape looks very
  #   similar to the one in the figure below:

  #       0.5 1.5 2.5
  #        | 1 | 2 |
  #        | | | | |
  #       [+   +   +] -- 0.5
  #       [+ 0 + 1 +] -- 1
  #       [+   +   +] -- 1.5
  #       [+ 1 * 1 +] -- 2
  #       [+   +   +] -- 2.5
  #       [+ 1 + 0 +] -- 3
  #       [+   +   +] -- 3.5

  #   `*` symbol indicates the point around which the shape is going to rotate.
  #   In this particular example the coordinates are x = 1.5, y = 2.5.

  #   When rotate_cw method is called the dot matrix will look like the one below:

  #       0.5 1.5 2.5 3.5
  #        | 1 | 2 | 3 |
  #        | | | | | | |
  #       [+   +   +   +] -- 0.5
  #       [+ 0 + 1 + 1 +] -- 1
  #       [+   + * +   +] -- 1.5
  #       [+ 1 * 1 + 0 +] -- 2
  #       [+   +   +   +] -- 2.5

  #   Note, the rotation point changed as well (x = 2, y = 1.5).

  #       0.5 1.5 2.5
  #        | 1 | 2 |
  #        | | | | |
  #       [+   +   +] -- 0.5
  #       [+ 1 + 1 +] -- 1
  #       [+   +   +] -- 1.5
  #       [+ 0 * 1 +] -- 2
  #       [+   +   +] -- 2.5
  #       [+ 0 + 1 +] -- 3
  #       [+   +   +] -- 3.5

  #   """
  #   Record.defrecord Shape,
  #     rotation_point: Point.new().x(0.0).y(0.0),
  #     dot_matrix: [[]] do
  #     def rotate_cw(this) do
  #       result = Shape.new()
  #       acc = lc(_r(inlist(:erlang.hd(this.dot_matrix()), do: [])))
  #       m = rotate_cw(this.dot_matrix, acc)
  #       y = this.rotation_point.x
  #       x = this.rotation_point.y
  #       result.dot_matrix(m).rotation_point(Point.new().x(x).y(y))
  #     end

  #     def rotate_ccw(this) do
  #       t1 = this.rotate_cw()
  #       t2 = t1.rotate_cw()
  #       t2.rotate_cw()
  #     end

  #     def rotate_cw([], acc) do
  #       acc
  #     end

  #     def rotate_cw([r | m], acc) do
  #       rotate_cw(m, zip(r, acc))
  #     end

  #     def zip([], []) do
  #       []
  #     end

  #     def zip([c | rt], [tr | tt]) do
  #       [[c | tr] | zip(rt, tt)]
  #     end
  #   end
end

# defrecord Field,
#     dot_matrix: [[0,0]] do
# end

# ],
# [
#     0.5 1.5 2.5 3.5 4.5
#      | 1 | 2 | 3 | 4 |
#      | | | | | | | | |
#     [+ + + + + + + + +] 0.5
#     [+ 1 + 1 * 1 + 1 +] 1
#     [+ + + + + + + + +] 1.5
# ],
# [
#     0.5 1.5 2.5
#      | 1 | 2 |
#      | | | | |
#     [+ + + + +]
#     [+ 1 + 1 +]
#     [+ 1 * 1 +]
#     [+ 1 + 1 +]
#     [+ + + + +]
# ],
# [
#     0.5 1.5 2.5 3.5
#      | 1 | 2 | 3 |
#      | | | | | | |
#     [+ + + + + + +] 0.5
#     [+ 1 + 1 + 1 +] 1
#     [+ + + * + + +] 1.5
#     [+ 0 + 0 + 1 +] 2
#     [+ + + + + + +] 2.5
# ],
# [
#     0.5 1.5 2.5 3.5
#      | 1 | 2 | 3 |
#      | | | | | | |
#     [+ + + + + + +] 0.5
#     [+ 1 + 1 + 1 +] 1
#     [+ + + * + + +] 1.5
#     [+ 1 + 0 + 0 +] 2
#     [+ + + + + + +] 2.5
# ]

# 0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5 0.5 1.5 2.5
#  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | 1 | 2 |
#  | | | | | | | | | | | | | | | | | | | | | | | | |
#  | | | | | | | | | | | | | | | | | | | | | | | | |
# [+   +   +   +   +   +   +   +   +   +   +   +   +]  .5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 1
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 1.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 2
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 2.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 3
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 3.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 4
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 4.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 5
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 5.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 6
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 6.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 7
# [+   +   +   +   +   +   +   +   +   +   +   +   +] 7.5
# [+ 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 + 0 +] 8
# [+   +   +   +   +   +   +   +   +   +   +   +   +]
