function restartGame = restartGame(obj)
            % Resets state and immediately starts a new game
            obj.resetGameState();
            obj.startGame();
        end