function showInstructions = showInstructions(obj)
            if obj.pauseGame == 0 
                obj.pauseGameFcn()
            end
            mathNote = sprintf('Mathematical Note: The fruit appearance interval is set to %d moves.', obj.fruits_interval);
            msg = {
                'SNAKE GAME INSTRUCTIONS'
                ''
                '1. Goal: Eat fruits to grow and increase your score.'
                '2. Controls: Use Arrow Keys or WASD to move and "p" to pause.'
                '3. Difficulty: Choose a level before starting to change speed and obstacles.'
                '4. Not eating fruits will cause your hungerbar to drop! Be careful!'
                '5. Game Over: Don''t hit the walls (on Hard), the obstacles, or yourself!'
                ''
                mathNote
            };
            uialert(obj.fig, msg, 'How to play', 'Icon','Info', 'CloseFcn',@(~,~) obj.pauseGameFcn());

        end