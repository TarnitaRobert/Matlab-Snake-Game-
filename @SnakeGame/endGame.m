 function endGame = endGame(obj)
            obj.gameOver = 1;
            obj.gameOverLabel.Visible = "on";
            obj.tryAgainBtn.Visible = "on";
            obj.snake_moves = 0;
            imshow('coffin.png', 'Parent', obj.moodImgAx);
         end