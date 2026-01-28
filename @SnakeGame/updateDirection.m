function updateDirection = updateDirection(obj, d)
            % Prevents the player from immediately reversing direction
            
            is_opposite = false;
            
            % Check if the requested direction 'd' is the opposite of the 'currentDirection'
            if (strcmp(obj.currentDirection, "up") && strcmp(d, "down")) || ...
               (strcmp(obj.currentDirection, "down") && strcmp(d, "up")) || ...
               (strcmp(obj.currentDirection, "left") && strcmp(d, "right")) || ...
               (strcmp(obj.currentDirection, "right") && strcmp(d, "left"))
               is_opposite = true;
            end
            
            % Only update nextDirection if 'd' is not the opposite
            if ~is_opposite
                obj.nextDirection = d;
                obj.upBtn.BackgroundColor = '#F0F0F0';
                obj.downBtn.BackgroundColor = '#F0F0F0';
                obj.leftBtn.BackgroundColor = '#F0F0F0';
                obj.rightBtn.BackgroundColor = '#F0F0F0';

                
            end
        end