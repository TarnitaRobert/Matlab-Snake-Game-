function setDifficulty = setDifficulty(obj, difficulty)
            if obj.snake_moves == 0;
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