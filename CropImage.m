clc
%clear all
close all
[coloms,rows]=size(app.Image); 

leftColumn =[];rightColumn=[];uprow=[];downrow=[];
i=1; stop_cr=[];
while isempty(stop_cr)
    leftColumn = app.Image(:, i); % Get column i 
    % Find where it's non-zero: 
    stop_cr = find(leftColumn <255, 1, 'first');     
    i=i+1
end
leftColumn=i;
i=rows; stop_cr=[];
while isempty(stop_cr)
    rightColumn = app.Image(:, i); % Get column 1 
    % Find where it's non-zero: 
    stop_cr = find(rightColumn <255, 1, 'first');     
    i=i-1
end
rightColumn=i;
i=1; stop_cr=[];
while isempty(stop_cr)
    uprow = app.Image(i, :); % Get column i 
    % Find where it's non-zero: 
    stop_cr = find(uprow <255, 1, 'first');     
    i=i+1
end
uprow=i;
i=coloms; stop_cr=[];
while isempty(stop_cr)
    downrow = app.Image(i, :); % Get column i 
    % Find where it's non-zero: 
    stop_cr = find(downrow <255, 1, 'first');     
    i=i-1
end
downrow=i;
croppedImage = imcrop(app.Image, [leftColumn, uprow, rightColumn-leftColumn+1, downrow-uprow+1]);
imshow(croppedImage)
