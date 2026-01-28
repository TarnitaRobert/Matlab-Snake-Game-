function pauseGameFcn = pauseGameFcn(obj)
            if obj.pauseGame == 1 && obj.gameOver == 0 && obj.snake_moves > 0
                obj.startGame()
            else 
                obj.pauseGame = 1;
            end

        end