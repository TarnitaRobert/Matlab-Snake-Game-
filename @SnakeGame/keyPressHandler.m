function keyPressHandler = keyPressHandler(obj, ~, event)
            % Handler for keyboard input
            pressedKey = event.Key;
            switch pressedKey
                % Arrows
                case 'uparrow'
                    obj.updateDirection('up');
                case 'downarrow'
                    obj.updateDirection('down');
                case 'leftarrow'
                    obj.updateDirection('left');
                case 'rightarrow'
                    obj.updateDirection('right');
                % WASD     
                case 'w' 
                    obj.updateDirection('up');
                case 's'
                    obj.updateDirection('down');
                case 'a'
                    obj.updateDirection('left');
                case 'd'
                    obj.updateDirection('right');       

                % enter for start/restart
                case 'return'
                    if obj.gameOver == 1
                        obj.restartGame();
                    elseif obj.gameOver == 0
                        obj.startGame();
                    end
                
                % pause/unpause
                case 'p'
                    obj.pauseGameFcn();
                otherwise
                    % Ignore other keys
            end
        end