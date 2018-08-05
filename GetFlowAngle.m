function [FlowAngle] = GetGravityAngle(fig)
[x,y] = ginput(1);
if x<0
    FlowAngle=rad2deg(atan(y/x))+180;
elseif x>=0 && y<0
    FlowAngle=rad2deg(atan(y/x))+360;
else
    FlowAngle=rad2deg(atan(y/x));
end
title ({'Determine on the polar grid the relative flow angle',...
                ['Flow Angle is ', num2str(round(FlowAngle)),' deg']}, 'FontSize', 16)
answeer = questdlg({'Are you sure?',['Your Flow angle is '...
    ,num2str(round(FlowAngle)),' deg'],['(relative to the horizon)']},...
    'Chossing Flow Angle','Yes','No','Yes')
if answeer == string('No')
    GetFlowAngle(fig)
end
end

