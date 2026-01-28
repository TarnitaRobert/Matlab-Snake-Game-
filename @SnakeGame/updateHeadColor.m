function updateHeadColor = updateHeadColor(obj, val)
            newHead = str2num(val);
            if length(newHead) == 3 && all(newHead <= 1) && all(newHead >= 0)
                obj.snakeHeadColor = newHead;
                obj.resetGameState();
            else
                uialert(obj.customPanelFig, 'Head must be 3 numbers: R G B', 'Error');
            end
        end