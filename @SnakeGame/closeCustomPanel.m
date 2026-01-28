function closeCustomPanel = closeCustomPanel(obj)
            if ~isempty(obj.customPanelFig) && isvalid(obj.customPanelFig)
                delete(obj.customPanelFig);
            end
            if obj.pauseGame == 1 
                obj.pauseGameFcn()
            end
            % focus back on the game figure  ? not working (to be fixed) 
            focus(obj.customSnakeBtn);
            focus(obj.fig);

        end