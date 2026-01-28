function resetGameState = resetGameState(obj)
            % Resets all game state variables for a new game or restart
            
            
            % Reset timer
            obj.snake_moves = 0;
            
            % Reset drawing matrix to black
            obj.mtx = zeros(obj.imgSize, obj.imgSize, 3);
            
            % Reset hunger
            obj.currentHunger = 100;
            imshow('happy_snake.png', 'Parent', obj.moodImgAx);

            % Reset snake body and length
            obj.currentLength = obj.initialLength;
            obj.snakeBody = zeros(obj.initialLength, 2);
            for l = 1:obj.initialLength
                obj.snakeBody(l,1) = obj.initialPosition(1);
                obj.snakeBody(l,2) = obj.initialPosition(2) + l - 1; 
            end
            
            % Draw initial snake body segments
            for i = 1:obj.initialLength
                row = obj.snakeBody(i, 1);
                col = obj.snakeBody(i,2);
                color_row_index = mod(i, size(obj.snakeBodyColor,1))+1;
                for c = 1:3
                    obj.mtx(row, col, c) = obj.snakeBodyColor(color_row_index,c);
                end
            end
             
           
            % Generate initial fruit
            obj.fruitPosition(1,:) = randi([1, obj.imgSize], 1, 2);
            while any(ismember(obj.snakeBody, obj.fruitPosition(1,:), 'rows')) || ...
                    any(ismember(obj.collisionBlocks, obj.fruitPosition(1,:), 'rows'))
                obj.fruitPosition(1, :) = randi([1, obj.imgSize], 1, 2);
            end
            
            % Draw initial head and fruit colors
            head_pos = obj.snakeBody(1,:);
            fruit_color_index = randi([1, length(obj.fruitColor)], 1, 1);
            for c = 1:3
                obj.mtx(head_pos(1), head_pos(2), c) = obj.snakeHeadColor(c);           
                obj.mtx(obj.fruitPosition(1,1), obj.fruitPosition(1,2), c) = obj.fruitColor(fruit_color_index,c);            
            end
            
            % Draw collision blocks
            for i = 1:length(obj.collisionBlocks)
                row = obj.collisionBlocks(i,1);
                col = obj.collisionBlocks(i,2);
                for c = 1:3
                    obj.mtx(row, col, c) = obj.collisionBlockColor(c);
                end
  
            end

            % Reset directions and flags
            obj.upBtn.BackgroundColor = '#F0F0F0';
            obj.downBtn.BackgroundColor = '#F0F0F0';
            obj.leftBtn.BackgroundColor = '#F0F0F0';
            obj.rightBtn.BackgroundColor = '#F0F0F0';
            obj.nextDirection = obj.initialDirection;
            obj.currentDirection = obj.initialDirection;
            obj.gameOver = 0;
            obj.pauseGame = 0;

            % Set UI visibility for pre-game state
            obj.gameOverLabel.Visible = "off";
            obj.tryAgainBtn.Visible = "off";
            obj.startGameBtn.Visible = "on";
            
            % Reset score label
            obj.scoreLabel.Text = "Score: 0";
            % Update graphics to show the initial board state
            imagesc(obj.ax, obj.mtx);
        end