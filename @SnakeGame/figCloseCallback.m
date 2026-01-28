function figCloseCallback = figCloseCallback(obj)
            obj.gameOver = 1; % Signal the game loop to stop
            delete(obj.fig);  % Close the figure
        end