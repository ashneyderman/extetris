defmodule Tetris.ShapesTest do
    use ExUnit.Case

    require Tetris.Point, as: Point
    require Tetris.Shape, as: Shape

    test "shape rotation cw" do
        rp = Point.new().x(1.5).y(2.0)

        s = Shape.new().
                 dot_matrix([[1,0],
                             [1,1],
                             [0,1]]).
                 rotation_point(rp)

        s1 = s.rotate_cw()

        assert(s1.dot_matrix === [[0,1,1],[1,1,0]], "dot matrix is not calculated correctly")
        assert(s1.rotation_point.x == 2.0)
        assert(s1.rotation_point.y == 1.5)
    end

    test "shape rotation ccw" do
        rp = Point.new().x(1.5).y(2.0)

        s = Shape.new().
                 dot_matrix([[1,1],
                             [0,1],
                             [0,1]]).
                 rotation_point(rp)

        s1 = s.rotate_ccw()

        assert(s1.dot_matrix === [[1,1,1],[1,0,0]], "dot matrix is not calculated correctly")
        assert(s1.rotation_point.x == 2.0)
        assert(s1.rotation_point.y == 1.5)
    end

    test "shape rotation 2 * cw" do
        rp = Point.new().x(1.5).y(2.0)

        s = Shape.new().
                 dot_matrix([[1,1],
                             [0,1],
                             [0,1]]).
                 rotation_point(rp)

        s0 = s.rotate_cw()
        s1 = s0.rotate_cw()

        assert(s1.dot_matrix === [[1,0],[1,0],[1,1]], "dot matrix is not calculated correctly")
        assert(s1.rotation_point.x == 1.5)
        assert(s1.rotation_point.y == 2.0)
    end

    test "shape rotation cw stick" do
        rp = Point.new().x(1.0).y(2.5)

        s = Shape.new().
                 dot_matrix([[1],
                             [1],
                             [1],
                             [1]]).
                 rotation_point(rp)

        s1 = s.rotate_ccw()

        assert(s1.dot_matrix === [[1,1,1,1]], "dot matrix is not calculated correctly")
        assert(s1.rotation_point.x == 2.5)
        assert(s1.rotation_point.y == 1.0)
    end
end
