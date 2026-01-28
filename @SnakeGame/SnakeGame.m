classdef SnakeGame < handle

    properties (Access = private)
        % --- Game Constants ---
        aspectRatio = 16/9;
        normalizeMtx = [1600 800 1600 800];
        imgSize = 100;
        initialLength = 25;
        initialPosition = [20 80]; % row, col
        initialDirection = "left";
        fruits_interval = 60;

        % --- Colors ---
        snakeHeadColor = [0 1 0];
        snakeBodyColor = [1  0  1; 1 1  .5];
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
        lastMoodCategory = 0;
        
        outerBlocks =  [0 2];
        hourglassBlocks = [0 2];
        innerRingBlocks = [0 2];
        centralCrossBlocks = [0 2];
        outerCornersBlocks = [0 2];
        outerSegmentsBlocks = [0 2];
        collisionBlocks = [0 2];
        

        
        nextDirection;      % Direction requested by user/keyboard
        currentDirection;   % Direction snake is actually moving6
        gameOver = 0;       % Flag: 0 = running, 1 = over
        pauseGame = 0;      % Flag: 0 = running, 1 = pause
        
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
        intructionsBtn;       
        pauseBtn;
        quitBtn;
        docBtn;
        
        % --- Sensor graph ---
        sensorAx;
        sensorLine;
        sensorData = zeros(1,100);

        % --- Hunger graph ---
        hungerBar; 
        hungerAx;
        moodImgAx;
        currentHunger = 100;
        decayValue = 0.2;

        % --- Custom snake panel ---
        customSnakeBtn;
        customPanelFig;
        colorEditField;
        selectedTarget = 'head';
        bodyTextArea;
    end

    methods 
        function obj = SnakeGame()
            % Constructor: Sets up the UI and initial state.
            obj.initializeGameUI();
        end
        

       % Gracefully shut down the game
       figCloseCallback = figCloseCallback(obj);
            
       % Reset the game state (called when difficulty changes
       % or game restarts
       resetGameState = resetGameState(obj);
       
       % Start the game, includes main game loop
       startGame = startGame(obj);
        
       % Function to restart the game (calls resetGameState and startGame)
       restartGame = restartGame(obj);
        
       
       % Key listener for keyboard inputs
       keyPressHandler =  keyPressHandler(obj, ~, event);
            
       % Update snake direction if possible
       updateDirection =  updateDirection(obj, d);
          
       % Shwow instruction pannel
       showInstructions = showInstructions(obj);
        
       % Pause game
       pauseGameFcn = pauseGameFcn(obj);
       
       % End game actions
       endGame = endGame(obj);
        
       % Create/open custom panel
       openCustomPanel = openCustomPanel(obj);
           
       % Update the Head Vector 
       updateHeadColor = updateHeadColor(obj, val);
         
        
       % Update the Body Matrix 
       updateBodyColors = updateBodyColors(obj, textLines);
           
       closeCustomPanel = closeCustomPanel(obj);
       evasiveQuitButton = evasiveQuitButton(obj);

      

    end

    methods (Access = private)
        setDifficulty = setDifficulty(obj, difficulty);
        function initializeGameUI(obj)
            
            
            % Constructor, sets up the UI and initial state.
            
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
                "WindowKeyPressFcn", @obj.keyPressHandler,...
                "ToolBar","none",'MenuBar', "none", 'Name', 'Snake Matlab');
            obj.fig.WindowState = 'maximized';
            obj.fig.WindowButtonMotionFcn = @(src, event) obj.evasiveQuitButton();
            obj.fig.Interruptible = 'on'; % not crash when snake is moving
            obj.fig.BusyAction = 'queue';
            obj.ax.HitTest = 'off';% capture mouse movements on figure instead of board
            obj.ax.PickableParts = 'none'; % blocks axis, prevens accidental clicks on the axis
            set(obj.fig,'defaultFigureMenuBar','none','defaultFigureToolBar','none');

            % Rewrite CloseRequestFcn to custom close function
            obj.fig.CloseRequestFcn = @(~,~) obj.figCloseCallback(); 

            % Create Axes for the game board
            obj.ax = uiaxes('Parent',obj.fig, "Visible", "off", ...
                "Units", "normalized", ...
                "Position", [.05 0 .56 .56*obj.aspectRatio], ...
                "XLim", [0, obj.imgSize+1], "YLim", [0, obj.imgSize+1]);
            disableDefaultInteractivity(obj.ax );
            % Create Axes for sensor (hearthbeat)
            obj.sensorAx = uiaxes(obj.fig, "Visible", "on", ...
                "Units", "normalized", ...
                "Position", [.65 0.15 .3 .15], ...
                "BackgroundColor", "Black", ...
                'XColor', 'none', 'Ycolor', 'none');
            title(obj.sensorAx, 'Proximity Alert', 'Color', 'r', 'FontSize', 14);
            obj.sensorLine = line(obj.sensorAx, 1:100, obj.sensorData, ...
                 "Color", 'red', "LineWidth", 1.5)

            
            % Create axes for hunger
            obj.hungerAx = uiaxes(obj.fig, "Visible", "on", ...
                "Units", "normalized", ...
                "Position", [.68 0.34 .08 .22], ...
                'BackgroundColor', 'Black', ...
                'YColor', 'y');
            title(obj.hungerAx, 'Hunger Bar', 'Color', 'y', 'FontSize',12);

            obj.hungerBar = bar(obj.hungerAx, obj.currentHunger,...
                "FaceColor", 'yellow', 'LineWidth',1);
            ylim(obj.hungerAx,[0,100]);
            
            % Mood image axis
            obj.moodImgAx =uiaxes(obj.fig, "Visible", "off", ...
                "Units", "normalized", ...
                "Position", [.75 0.29 .25 .25], ...
                'BackgroundColor', 'none', ...
                'YColor', 'y');
            imshow('happy_snake.png', 'Parent', obj.moodImgAx);
            disableDefaultInteractivity(obj.moodImgAx );

            % UI Buttons for movement (call methods on the object)
            obj.upBtn = uibutton(obj.fig, 'Text', 'up', ...
                'Position', obj.normalizeMtx .* [0.79 0.68 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('up'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');

            obj.downBtn = uibutton(obj.fig, 'Text', 'down', ...
                'Position', obj.normalizeMtx .* [0.79 0.56 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('down'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');

            obj.leftBtn = uibutton(obj.fig, 'Text', 'left', ...
                'Position', obj.normalizeMtx .* [0.7 0.62 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('left'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');

            obj.rightBtn = uibutton(obj.fig, 'Text', 'right', ...
                'Position', obj.normalizeMtx .* [0.88 0.62 .05 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.updateDirection('right'), ...
                'BackgroundColor','#97939c', ...
                'FontColor','Black');
            
            % Custom snake panel button 
            obj.customSnakeBtn = uibutton(obj.fig, 'Text', 'Customize Snake', ...
                'Position', obj.normalizeMtx .* [0.70 0.1 0.1 0.04], ...
                'BackgroundColor', '#9C27B0', ...
                'FontColor', 'white', 'Fontsize', 19, ...
                'ButtonPushedFcn', @(~,~) obj.openCustomPanel());

            % Pause button
            obj.pauseBtn = uibutton(obj.fig, 'Text', 'Pause', ...
                'Position', obj.normalizeMtx .* [0.70 0.04 0.1 0.04], ...
                'BackgroundColor', '#FF9800', ...
                'FontColor', 'White', 'Fontsize', 19,...
                'ButtonPushedFcn', @(~,~) obj.pauseGameFcn());
            

            % Quit button
            obj.quitBtn = uibutton(obj.fig, 'Text', 'Quit game', ...
                 'Position', obj.normalizeMtx .* [0.90 0.93 0.08 0.04], ...
                 'BackgroundColor', 'Red', ...
                 'FontColor', 'White', 'Fontsize', 19, ...
                 'ButtonPushedFcn', @(~,~) obj.figCloseCallback());
           
            % Documentation button
            obj.docBtn = uibutton(obj.fig, 'Text', 'Documentation', ...
                 'Position', obj.normalizeMtx .* [0.82 0.04 0.1 0.04], ...
                 'BackgroundColor', '#4CAF50', ...
                 'FontColor', 'White', 'Fontsize', 19, ...
                 'ButtonPushedFcn', @(~,~) winopen("Tarnita_Robert_CAG.pdf"));
           
            % Intructions button
            obj.intructionsBtn = uibutton(obj.fig, 'Text', 'How to play', ...
                'Position', obj.normalizeMtx .* [0.82 0.1 0.1 0.04], ...                    
                'ButtonPushedFcn', @(~,~) obj.showInstructions(), ...                
                'FontColor', 'Black','FontSize', 19, ...
                'BackgroundColor', '#2196F3', ...
                'FontColor', 'White');

            % Game Over Label
            obj.gameOverLabel = uilabel(obj.fig, 'Text', "Game Over!", ...
                "FontColor", "Red", "FontSize", 50, ...
                "Position", obj.normalizeMtx .* [0.08 0.50 0.50 0.15], ...
                "HorizontalAlignment", "center", ...
                "Visible", "off");
            
            % Try Again button (calls restartGame)
            obj.tryAgainBtn = uibutton(obj.fig, 'Text', 'Try again', ...
                'Position', obj.normalizeMtx .* [0.255 0.40 0.15 0.08], ...                    
                'ButtonPushedFcn', @(~,~) obj.restartGame(), ...
                'Visible', 'off', ...
                'BackgroundColor', '#2196F3', ...
                'FontWeight', 'bold', 'FontSize', 24, 'FontColor', 'white');

            % Start Game button (calls startGame)
            obj.startGameBtn = uibutton(obj.fig, 'Text', 'Start game', ...
                'Position', obj.normalizeMtx .* [0.255 0.45 0.15 0.08], ...                    
                'ButtonPushedFcn', @(~,~) obj.startGame(), ...
                'Visible', 'on', 'FontSize', 24, 'FontWeight','bold', ...
                'BackgroundColor','#4CAF50', 'FontColor', 'white');

            % Score label
            obj.scoreLabel = uilabel(obj.fig, 'Text','Score: 0',...
                             'Position', obj.normalizeMtx .* [0.65 0.88 .1 .05], ...
                             'HorizontalAlignment','center', ...
                             'FontColor', 'Yellow', 'FontSize',35);
            
           % Easy button
           obj.easyBtn = uibutton(obj.fig, 'Text', 'Easy', ...
                'Position', obj.normalizeMtx .* [0.70 0.80 .07 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('easy'), ...
                'FontColor', 'Black', 'FontSize', 19);


           % Medium button
           obj.mediumBtn = uibutton(obj.fig, 'Text', 'Medium', ...
                'Position', obj.normalizeMtx .* [0.78 0.80 .07 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('medium'), ...           
                'FontColor', 'Black', 'FontSize', 19);

           % Hard button
           obj.hardBtn = uibutton(obj.fig, 'Text', 'Hard', ...
                'Position', obj.normalizeMtx .* [0.86 0.80 .07 .05], ...                    
                'ButtonPushedFcn', @(~,~) obj.setDifficulty('hard'), ...                
                'FontColor', 'Black', 'FontSize', 19);          

           % Hidden component for stealing focus
           obj.customSnakeBtn = uieditfield(obj.fig, 'numeric', ...
                'Position', [1 1 1 1], ... 
                'BackgroundColor', [0 0 0], ...
                'FontColor', [0 0 0]);           
            % Initial state setup
           obj.setDifficulty('easy');
           obj.resetGameState();

          

        end
       
    end
  
end