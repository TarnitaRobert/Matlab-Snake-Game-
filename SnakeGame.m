classdef SnakeGame < handle

    properties (Access = private)
        % --- Game Constants ---
        aspectRatio = 16/9;
        normalizeMtx = [1600 800 1600 800];
        imgSize = 100;
        initialLength = 4;
        initialPosition = [20 80]; % row, col
        initialDirection = "left";
        fruits_interval = 60;

        % --- Colors ---
        snakeHeadColor = [0, 0.9, 0.5];
        snakeBodyColor = [0.3, 0.2, 0.8; 0.4, 0.6, 1; 1 0.41 0.71];
        collisionBlockColor = [1 1 1];
        fruitColor = [
                        1, 0.8, 0;    
                        1, 0.2, 0;   
                        0.9, 0.1, 0.9; 
                        0, 1, 0.2;    
                        ];
        blackColor = [0 0 0];
        
        % --- Dynamic Game State Variables ---
        mtx;                % Image matrix for drawing
        snakeBody;          % Matrix storing snake segment coordinates
        currentLength;
        fruitPosition;
        snake_moves = 0;
        gameSpeed; % Game speed

        outerBlocks =  [0 2];
        hourglassBlocks = [0 2];
        innerRingBlocks = [0 2];
        centralCrossBlocks = [0 2];
        outerCornersBlocks = [0 2];
        outerSegmentsBlocks = [0 2];
        collisionBlocks = [0 2];


        
        nextDirection;      % Direction requested by user/keyboard
        currentDirection;   % Direction snake is actually moving
        gameOver = 0;       % Flag: 0 = running, 1 = over
        
        % --- Graphics  ---
        fig;
        ax;
        gameOverLabel;
        startGameBtn;
        tryAgainBtn;
        scoreLabel;
        easyBtn;
        mediumBtn;
        hardBtn;
        upBtn;
        downBtn;
        leftBtn;
        rightBtn;
    end

    methods 
        function obj = SnakeGame()
            % Constructor: Sets up the UI and initial state.
            
            % Create and calculate all obstacles

            % Outer bounds 
            obj.outerBlocks = [(1:100)', ones(100,1); (1:100)', 100*ones(100,1); % lateral
                                ones(100, 1), (1:100)'; 100*ones(100, 1), (1:100)']; % vertical
            
            % Hourglass Style Obstacle
            obj.hourglassBlocks = [24 * ones(51, 1), (25:75)';76 * ones(51, 1), (25:75)'; 
                                 (40:60)', 25 * ones(21, 1); (40:60)', 75 * ones(21, 1)];
            
            % Central Cross Obstacle
            obj.centralCrossBlocks = [50 * ones(41, 1), (30:70)';   % Horizontal Bar (Row 50)
                                  (30:70)', 50 * ones(41, 1)];  % Vertical Bar (Col 50)
            
            % Inner Rings Obstacle
           obj.innerRingBlocks = [
                30 * ones(16, 1), (30:45)';
                30 * ones(15, 1), (56:70)';
                
                70 * ones(16, 1), (30:45)';
                70 * ones(15, 1), (56:70)';
                
                (30:45)', 30 * ones(16, 1);
                (56:70)', 30 * ones(15, 1);
                
                (30:45)', 70 * ones(16, 1);
                (56:70)', 70 * ones(15, 1)
            ];

            % Outer Segments

            obj.outerSegmentsBlocks = [
                (35:65)', ones(31,1);
                (35:65)', 100*ones(31,1);
                ones(31,1), (35:65)';
                100*ones(31,1), (35:65)';
            ];

            % Outer Corners
            obj.outerCornersBlocks = [
                % Top-Left Corner (Rows 1-10, Cols 1-10)
                ones(10, 1), (1:10)';        
                (1:10)', ones(10, 1);       
                
                % Top-Right Corner (Rows 1-10, Cols 91-100)
                ones(10, 1), (91:100)';     
                (1:10)', 100 * ones(10, 1);  
                
                % Bottom-Left Corner (Rows 91-100, Cols 1-10)
                100 * ones(10, 1), (1:10)';  
                (91:100)', ones(10, 1);      
                
                % Bottom-Right Corner (Rows 91-100, Cols 91-100)
                100 * ones(10, 1), (91:100)'; 
                (91:100)', 100 * ones(10, 1)  
            ];
               

            % --- UI SETUP (Figure and Controls) ---
            obj.fig = uifigure("Position", [160, 160, 1600, 800], ...
                "WindowKeyPressFcn", @obj.keyPressHandler);
            
            % Rewrite CloseRequestFcn to custom close function
            obj.fig.CloseRequestFcn = @(~,~) obj.figCloseCallback(); 

            % Create Axes for the game board
            obj.ax = uiaxes(obj.fig, "Visible", "off", ...
                "Units", "normalized", ...
                "Position", [.05 0 .56 .56*obj.aspectRatio], ...
                "XLim", [0, obj.imgSize+1], "YLim", [0, obj.imgSize+1]);

            % UI Buttons for movement (call methods on the object)
            obj.upBtn = uibutton(obj.fig, 'Text', 'up', ...
                'Position', obj.normalizeMtx .* [0.8 0.6 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('up'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');
            obj.downBtn = uibutton(obj.fig, 'Text', 'down', ...
                'Position', obj.normalizeMtx .* [0.8 0.4 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('down'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');
            obj.leftBtn = uibutton(obj.fig, 'Text', 'left', ...
                'Position', obj.normalizeMtx .* [0.7 0.5 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('left'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');
            obj.rightBtn = uibutton(obj.fig, 'Text', 'right', ...
                'Position', obj.normalizeMtx .* [0.9 0.5 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('right'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');

            % Quit button
            uibutton(obj.fig, 'Text', 'Quit game', ...
                'Position', obj.normalizeMtx .* [0.9 0.1 .05 .05], ...
                'BackgroundColor', 'Red', ...
                'ButtonPushedFcn', @(~,~) obj.figCloseCallback());
            
            % Game Over Label
            obj.gameOverLabel = uilabel(obj.fig, 'Text', "Game Over!", ...
                "FontColor", "Red", "FontSize", 50, ...
                "Position", obj.normalizeMtx .* [0.08 .5 .5 .5], ...
                "HorizontalAlignment", "center", ...
                "Visible", "off");
            
            % Try Again button (calls restartGame)
            obj.tryAgainBtn = uibutton(obj.fig, 'Text', 'Try again', ...
                'Position', obj.normalizeMtx .* [0.8 0.2 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.restartGame(), ...
                'Visible', 'off');

            % Start Game button (calls startGame)
            obj.startGameBtn = uibutton(obj.fig, 'Text', 'Start game', ...
                'Position', obj.normalizeMtx .* [0.8 0.2 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.startGame(), ...
                'Visible', 'on');

            % Score label
            obj.scoreLabel = uilabel(obj.fig, 'Text','Score: 0',...
                             'Position', obj.normalizeMtx .* [0.65 0.85 .1 .05], ...
                             'HorizontalAlignment','center', ...
                             'FontColor', 'Yellow', 'FontSize',35);
            
           % Easy button
           obj.easyBtn = uibutton(obj.fig, 'Text', 'Easy', ...
                'Position', obj.normalizeMtx .* [0.7 0.75 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('easy'), ...
                'FontColor', 'Black', 'FontSize', 19);


           % Medium button
           obj.mediumBtn = uibutton(obj.fig, 'Text', 'Medium', ...
                'Position', obj.normalizeMtx .* [0.8 0.75 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('medium'), ...           
                'FontColor', 'Black', 'FontSize', 19);

           % Hard button
           obj.hardBtn = uibutton(obj.fig, 'Text', 'Hard', ...
                'Position', obj.normalizeMtx .* [0.9 0.75 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('hard'), ...                
                'FontColor', 'Black', 'FontSize', 19);

            
            % Initial state setup
            obj.setDifficulty('easy');
            obj.resetGameState();
        end




        function figCloseCallback(obj)
            % Function to gracefully shut down the game
            obj.gameOver = 1; % Signal the game loop to stop
            delete(obj.fig);  % Close the figure
        end

        function resetGameState(obj)
            % Resets all game state variables for a new game or restart
            
            
            % Reset timer
            obj.snake_moves = 0;
            
            % Reset drawing matrix to black
            obj.mtx = zeros(obj.imgSize, obj.imgSize, 3);
            
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

            % Set UI visibility for pre-game state
            obj.gameOverLabel.Visible = "off";
            obj.tryAgainBtn.Visible = "off";
            obj.startGameBtn.Visible = "on";
            
            % Reset score label
            obj.scoreLabel.Text = "Score: 0";
            % Update graphics to show the initial board state
            imagesc(obj.ax, obj.mtx);
        end

        function startGame(obj)
            % Hides the start button and begins the main game loop
            
            % Only proceed if the game isn't already running
            if obj.gameOver == 0
                obj.startGameBtn.Visible = 'off';
                obj.gameOverLabel.Visible = "off";
                obj.tryAgainBtn.Visible = "off";
            end
            
            focus(obj.fig); % Refocus on figure for keys handling

            % --- MAIN GAME LOOP ---
            while obj.gameOver == 0
                % Safety check: break the loop if the figure is closed
                if ~isvalid(obj.fig)
                    break;
                end
                
                tail_position = obj.snakeBody(end, :);

                % 1. Shift body positions (move body segments to follow the head)
                for i = size(obj.snakeBody, 1):-1:2
                    obj.snakeBody(i, :) = obj.snakeBody(i-1, :);
                end
                
                % Commit to the next direction
                obj.currentDirection = obj.nextDirection;
                
                % 2. Calculate new head position (with original min/max wrapping logic)
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

                % 3. Check for head collision with body or blocks (Game Over)
                if any(ismember(obj.snakeBody(2:end,:), head_position, 'rows')) || ...
                    any(ismember(obj.collisionBlocks, head_position, "rows"))
                    obj.gameOverLabel.Visible = "on";
                    obj.tryAgainBtn.Visible = "on";
                    obj.gameOver = 1;
                    obj.snake_moves = 0;
                    break; % Exit the loop
                end

                          
                % 4. Check for fruit consumption

                [fruit_eat, fruit_index] = ismember(head_position, obj.fruitPosition, 'rows');
                if fruit_eat == 1
                    % Fruit eaten: Grow the snake by adding the old tail back
                    obj.snakeBody(end + 1, :) = tail_position;
                    obj.currentLength = obj.currentLength + 1;

                    % Remove eaten fruit
                    obj.fruitPosition(fruit_index, :) = [];
                end
                
                % 5. Drawing and Matrix Update
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
                imagesc(obj.ax, obj.mtx); 
                pause(1/obj.gameSpeed);
            end
        end
        
      
        function restartGame(obj)
            % Resets state and immediately starts a new game
            obj.resetGameState();
            obj.startGame();
        end

        function keyPressHandler(obj, ~, event)
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
                otherwise
                    % Ignore other keys
            end
        end

        function updateDirection(obj, d)
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
    end

    methods (Access = private)
       
        function setDifficulty(obj, difficulty)
            if obj.snake_moves == 0
            obj.easyBtn.BackgroundColor='#F0F0F0';
            obj.mediumBtn.BackgroundColor='#F0F0F0';
            obj.hardBtn.BackgroundColor='#F0F0F0';
    
                switch difficulty
                    case 'easy'
                        obj.collisionBlocks= obj.centralCrossBlocks;
                        obj.gameSpeed = 30;
                        obj.easyBtn.BackgroundColor='#FFC800';
    
                    case 'medium'
                        obj.collisionBlocks = [obj.outerCornersBlocks;
                                            obj.outerSegmentsBlocks;
                                            obj.hourglassBlocks];
                        obj.gameSpeed = 45;
                        obj.mediumBtn.BackgroundColor='#FFC800';
    
                    case 'hard'
                        obj.collisionBlocks = [obj.outerCornersBlocks; 
                                        obj.hourglassBlocks; 
                                        obj.centralCrossBlocks;
                                        obj.outerBlocks;
                                        obj.innerRingBlocks;
                                        ];
                        obj.gameSpeed = 60;
                        obj.hardBtn.BackgroundColor='#FFC800';
                        
                    otherwise 
                end
                obj.resetGameState();
            end
        end
    end
  
end