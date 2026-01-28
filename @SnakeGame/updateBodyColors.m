function updateBodyColors = updateBodyColors(obj, textLines)
            try
                % Convert the multi-line text into a matrix
                newBodyMtx = str2num(strjoin(textLines, '; '));
                
                if size(newBodyMtx, 2) == 3 && all(newBodyMtx(:) <= 1) && all(newBodyMtx(:) >= 0)
                    obj.snakeBodyColor = newBodyMtx;
                    obj.resetGameState();
                else
                    uialert(obj.customPanelFig, 'Each line must have 3 RGB values.', 'Error');
                end
            catch
                uialert(obj.customPanelFig, 'Invalid Matrix format.', 'Error');
            end
        end