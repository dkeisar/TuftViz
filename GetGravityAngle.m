function [GravityAngle] = GetGravityAngle(fig)
[x,y] = ginput(1);
if x<0
    GravityAngle=rad2deg(atan(y/x))+180;
elseif x>=0 && y<0
    GravityAngle=rad2deg(atan(y/x))+360;
else
    GravityAngle=rad2deg(atan(y/x));
end
title ({'Determine on the polar grid the relative gravitational or rest angle',...
                ['Flow Angle is ', num2str(round(GravityAngle)),' deg']}, 'FontSize', 16)
answeer = questdlg({'Are you sure?',['Your gravitational angle is '...
    ,num2str(round(GravityAngle)),' deg'],['(relative to the horizon)']},...
    'Chossing gravitational Angle','Yes','No','Yes')
if answeer == string('No')
    GetFlowAngle(fig)
end
end

