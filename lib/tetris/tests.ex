defmodule Tetris.Tests do

    require Tetris.Shape, as: Shape
    require Tetris.Point, as: Point

    require Quaff.Constants
    Quaff.Constants.include_lib("cecho/include/cecho.hrl")

    def windows(argv \\ System.argv) do
        :cecho.noecho()

        w0 = :cecho.newwin(20, 15, 5, 5)
        w1 = :cecho.newwin(20, 15, 5, 30)

        :cecho.wmove(w0, 1, 1)
        :cecho.waddstr(w0, 'test0')
        :cecho.wrefresh(w0)

        :timer.sleep(2000)

        :cecho.wmove(w1, 1, 1)
        :cecho.waddstr(w1, 'test1')
        :cecho.wrefresh(w1)
        :timer.sleep(2000)
    end

    def min_max(argv \\ System.argv) do
        :ok = :cecho.noecho()
        :ok = :cecho.nl()

        {maxy, maxx} = :cecho.getmaxyx()

        :cecho.move(0,0)
        :cecho.addstr('0')
        :cecho.move(0,maxx-1)
        :cecho.addstr('X')
        :cecho.move(maxy-1,0)
        :cecho.addstr('Y')
        :cecho.move(maxy-1,maxx-1)
        :cecho.addstr('0')

        :ok = :cecho.move(div(maxy,2),div(maxx, 2))
        :ok = :cecho.addstr('Max-y: ' ++ :erlang.integer_to_list(maxy)) 
        :ok = :cecho.move(div(maxy,2)+2,div(maxx, 2))
        :ok = :cecho.addstr('Max-x: ' ++ :erlang.integer_to_list(maxx)) 
        
        # :ok = :cecho.addch(10)         
        # :ok = :cecho.addstr('Max-y: ' ++ :erlang.integer_to_list(maxy)) 
        # :ok = :cecho.addch(10)         
        # :ok = :cecho.addstr('Max-x: ' ++ :erlang.integer_to_list(maxx)) 

        :ok = :cecho.move(div(maxy,2)+10,maxx-1)
        :cecho.addstr('X')
        :cecho.refresh()

        :ok = :cecho.move(div(maxy,2)+10,div(maxx, 2))
        :ok = :cecho.addch(10)
        :cecho.refresh()

        :timer.sleep(5000)
    end

    def input(argv \\ System.argv) do
        :ok = :cecho.echo()
        :ok = :cecho.cbreak()
        :ok = :cecho.scrollok(0, true)
        :cecho.move(2,2)
        :cecho.addstr('Enter your name: ')
        :cecho.refresh()
        do_ipnut()
    end

    defp do_ipnut() do
        :ok = :cecho.scrollok(0, false)
        ch = :cecho.getch()
        {y,x} = :cecho.getyx()
        #:cecho.mvaddstr(y+1, x, :erlang.integer_to_list(ch))
        :cecho.refresh()
        do_ipnut()
    end

    def draw_test() do
        :ok = :cecho.noecho()
        :ok = :cecho.cbreak()
        :ok = :cecho.curs_set(@ceCURS_INVISIBLE)              
        disp = Point.new().x(2).y(2)
        rp = Point.new().x(2).y(1.5)
        shape = Shape.new().dot_matrix([[1,1,1],[1,0,0]]).rotation_point(rp)
        draw_with_input(disp, shape)                
    end 

    def draw_with_input(disp, shape) do
        :cecho.erase()
        draw_shape(disp,shape)
        :cecho.refresh()
        :cecho.move(disp.y,disp.x)
        input = :cecho.getch()

        nShape = shape.rotate_cw()
        draw_with_input(disp, nShape)

        # case input do
        #     @ceKEY_ESC ->

        #         :ok
        #     @ceKEY_UP ->
        #         nShape = shape.rotate_cw()
        #         draw_with_input(disp, nShape)
        #     @ceKEY_DOWN ->
        #         nShape = shape.rotate_ccw()
        #         draw_with_input(disp, nShape)
        #     _ ->
        #         draw_with_input(disp, nShape)
        # end
    end

    # def dstr(str) do

    #     {y,x} :cecho.getyx()
        
    # end
    
    
    def draw_shape(disp,shape) do
        draw_shape(disp,@ceACS_BLOCK,shape.dot_matrix)
    end

    def draw_shape(_disp,_char,[]) do
        :ok
    end
    def draw_shape(disp,char,[row|m]) do
        draw_row(disp,char,row)
        draw_shape(disp.next_row(),char,m)
    end

    def draw_row(disp,char,[]) do
        :ok
    end
    def draw_row(disp,char,[cell|cells]) do
       draw_cell(disp,char,cell)
       draw_row(disp.next_col(),char,cells) 
    end

    def draw_cell(_disp,_char,0) do
        :ok
    end
    def draw_cell(disp,char,1) do
        :cecho.mvaddch(disp.y,disp.x,char)
    end

end