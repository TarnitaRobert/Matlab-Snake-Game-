 function startGame = startGame(obj)
            % Hides the start button and begins the main game loop
            obj.pauseGame = 0;
            % Only proceed if the game isn't already running
            if obj.gameOver == 0
                obj.startGameBtn.Visible = 'off';
                obj.gameOverLabel.Visible = "off";
                obj.tryAgainBtn.Visible = "off";
            end
            
            focus(obj.fig); % Refocus on figure for keys handling

            % --- MAIN GAME LOOP ---
            while obj.gameOver == 0 && obj.pauseGame == 0 
                % Check hunger and stress level 
                if obj.currentHunger == 0
                    obj.endGame();
                end

                % update  mood image

                % Determine current category: 4=Happy, 3=Neutral, 2=Hungry, 1=Sad
                if obj.currentHunger > 60,
                    currentCat = 4;
                elseif obj.currentHunger > 50, 
                    currentCat = 3;
                elseif obj.currentHunger > 25,
                    currentCat = 2;
                elseif obj.currentHunger > 0,                         
                    currentCat = 1;
                else 
                    currentCat = 0;
                end
                
                % Update if the category has changed
                if isempty(obj.lastMoodCategory) || currentCat ~= obj.lastMoodCategory
                    % Clear the previous image so they don't stack up (huge
                    % lag fix)
                    cla(obj.moodImgAx); 
                    
                    switch currentCat
                        case 4, imshow('happy_snake.png', 'Parent', obj.moodImgAx);
                        case 3, imshow('neutral_snake.png', 'Parent', obj.moodImgAx);
                        case 2, imshow('hungry_snake.png', 'Parent', obj.moodImgAx);
                        case 1, imshow('sad_snake.png', 'Parent', obj.moodImgAx);
                        case 0, imshow('coffin.png', 'Parent', obj.moodImgAx);

                    end
                    obj.lastMoodCategory = currentCat; 
                end


                % Safety check: break the loop if the figure is closed
                if ~isvalid(obj.fig)
                    break;
                end
                tail_position = obj.snakeBody(end, :);
                
                % --- old logic ---
                % Shift body positions (move body segments to follow the
                % head)

                % for i = size(obj.snakeBody, 1):-1:2
                %    obj.snakeBody(i, :) = obj.snakeBody(i-1, :);
                % end
                
                % Shift all segments at once (Vectorized Matrix Slicing)
                obj.snakeBody(2:end, :) = obj.snakeBody(1:end-1, :);

                % Commit to the next direction
                obj.currentDirection = obj.nextDirection;
                
                % Calculate new head position (with original min/max wrapping logic)
                % The head position is updated directly in the snakeBody matrix
                
                switch obj.currentDirection
                    
                    case "up"           
                        if obj.snakeBody(1,1) == 1
                            obj.snakeBody(1,1) = obj.imgSize; 
                        else
                            % Row decreases (moves up)
                            obj.snakeBody(1,1) = max(obj.snakeBody(1,1) -1, 1);
                        end
                        obj.upBtn.BackgroundColor = '#13a0f2';

                    case "down"
                        if obj.snakeBody(1,1) == obj.imgSize 
                            obj.snakeBody(1,1) = 1;
                        else               
                            % Row increases (moves down)
                            obj.snakeBody(1,1) = min(obj.snakeBody(1,1) +1 , obj.imgSize);
                        end
                        obj.downBtn.BackgroundColor = '#13a0f2';

                    case "left"
                        if obj.snakeBody(1,2) == 1
                            obj.snakeBody(1,2) = obj.imgSize;
                        else
                            % Column decreases (moves left)
                            obj.snakeBody(1,2) = max(obj.snakeBody(1,2) - 1 , 1);
                        end
                        obj.leftBtn.BackgroundColor = '#13a0f2';

                    case "right"
                        if obj.snakeBody(1,2) == obj.imgSize
                            obj.snakeBody(1,2) = 1;
                        else
                            % Column increases (moves right)
                            obj.snakeBody(1,2) = min(obj.snakeBody(1,2) + 1, obj.imgSize); 
                        end  
                        obj.rightBtn.BackgroundColor = '#13a0f2';

                    otherwise
                        % No change
                end
                
                head_position= obj.snakeBody(1, :); % Current head position
                
                % Add another fruit at certain movements
                obj.snake_moves = obj.snake_moves + 1;
                if mod(obj.snake_moves, obj.fruits_interval) == 0 
                    newFruit= randi([1, obj.imgSize], 1, 2);
                    while any(ismember(obj.snakeBody, newFruit, "rows")) || ...
                          any(ismember(obj.fruitPosition, newFruit, 'rows')) || ...
                          any(ismember(obj.collisionBlocks, newFruit, 'rows'))
                         newFruit= randi([1, obj.imgSize], 1, 2);
                    end
                        obj.fruitPosition(end+1, :) = newFruit; 

                        % Draw new fruit
                        fruit_color_index = randi([1, length(obj.fruitColor)], 1, 1);

                        for c = 1:3 
                            obj.mtx(newFruit(1), newFruit(2), c) = obj.fruitColor(fruit_color_index,c);
                        end

                end

                % Check for head collision with body or blocks (Game Over)
                if any(ismember(obj.snakeBody(2:end,:), head_position, 'rows')) || ...
                    any(ismember(obj.collisionBlocks, head_position, "rows"))
                    obj.endGame();
                    break; % Exit the loop
                end

                          
                % Check for fruit consumption

                [fruit_eat, fruit_index] = ismember(head_position, obj.fruitPosition, 'rows');
                if fruit_eat == 1
                    % Fruit eaten: Grow the snake by adding the old tail back
                    obj.snakeBody(end + 1, :) = tail_position;
                    obj.currentLength = obj.currentLength + 1;

                    % Remove eaten fruit
                    obj.fruitPosition(fruit_index, :) = [];
                end
                
                % Proximity sensor update
                distToBlocks = sqrt(sum((head_position - obj.collisionBlocks) .^2, 2));
                minDist = max(min(distToBlocks), 1); % add threshold for distance
                
                % new frequency and new amplitude
                amplitude = 10/minDist;
                frequency = min(15/minDist, 2);
                new_val = amplitude * sin(obj.snake_moves * frequency);

                obj.sensorData = [obj.sensorData(2:end), new_val]; % drop last value and add new value
                set(obj.sensorLine, 'YData', obj.sensorData); % update line
                ylim(obj.sensorAx, [-15 15]); % consistent scale
                

                % Hunger bar update
                if fruit_eat == 1
                    obj.currentHunger = min(obj.currentHunger + 30, 100);
                end
                obj.currentHunger = max(obj.currentHunger - obj.decayValue, 0);
 
                
                set(obj.hungerBar, 'YData', obj.currentHunger);
               
                % Drawing and Matrix Update
                for c = 1:3 % for each color channel 
                    
                    % Draw new head (at its new position)
                    obj.mtx(head_position(1), head_position(2), c) = obj.snakeHeadColor(c); 
                    
                    % Color the body alternating colors
                    for i = 2:obj.currentLength
                        color_row_index = mod(i, size(obj.snakeBodyColor,1))+1;
                        obj.mtx(obj.snakeBody(i,1), obj.snakeBody(i,2), c) = obj.snakeBodyColor(color_row_index,c); 
                        
                    end
                    if fruit_eat == 0
                        % Remove the tail (only if no fruit was eaten)
                        obj.mtx(tail_position(1), tail_position(2), c) = obj.blackColor(c);    
                    end
                end
                
                % Update score label
                obj.scoreLabel.Text = "Score: " + string(obj.currentLength-obj.initialLength) ;

                % Final graphics update and pause
                
                % Look for any existing image sitting on your game axes
                hImg = findobj(obj.ax, 'Type', 'image');
                
                if isempty(hImg)
                   % Create the image if it doesn't exist
                    hImg = image(obj.ax, 'CData', obj.mtx);
                else
                    % If it exists swap the pixels for optimisation
                    set(hImg, 'CData', obj.mtx);
                end
                
                % force refreshh
                drawnow limitrate; 
                
               % pause
                pause(1/obj.gameSpeed);
            end
        end