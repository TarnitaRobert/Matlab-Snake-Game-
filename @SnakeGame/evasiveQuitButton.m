function evasiveQuitButton = evasiveQuitButton(obj)
    drawnow limitrate;
    mousePos = obj.fig.CurrentPoint;
    btnPos = obj.quitBtn.Position;
    btnCenter = [btnPos(1) + btnPos(3)/2, btnPos(2) + btnPos(4)/2];  
    dist = sqrt((mousePos(1) - btnCenter(1))^2 + (mousePos(2) - btnCenter(2))^2);   
    if dist < 50
        figSize = obj.fig.Position;
        newX = rand * (figSize(3) - btnPos(3));
        newY = rand * (figSize(4) - btnPos(4));
        obj.quitBtn.Position(1:2) = [newX, newY];     
    end
end