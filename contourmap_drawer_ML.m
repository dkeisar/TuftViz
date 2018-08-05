function [Q] = contourmap_drawer_ML(weightVector,tuftMat,CroppedMask,I,dontplot)
%%
% This function gets data on the labled tuft, and draws probability map of
% whether the flow is attached or not only by the orientation of the tuft
%
% -graindata:               Contains the centroids of the labled data
% -graindata_Orientation:   The orientation of the labled data in degrees
%                           as respect to the x-axis
% -CroppedMask:             The Mask that was chosen for the image by the
%                           user or by the algorithm
% -I:                       The masked image before the segmentation
%                           prosses
%%
% This part classifies the labled data to x,y vectors

Lables=tuftMat*(weightVector');
len=length(Lables);
x=zeros(len,1);y=zeros(len,1); %initialize
[h,l]=size(I);
for i=1:len
    %classify to the x and y location
    x(i)=tuftMat(i,1)*l; y(i)=tuftMat(i,2)*h;
end
%%
% This part classifies the labled data to X,Y,U,V grid by interpulating
% the x,y,u,v data (v4-exect solution) for all the X,Y grid
% U and V are just the diraction grid of the labled tufts
x=round(x);y=round(y);      %round to the nearest pixle of the labeled data
% meshgrid X and Y to the size of image
[X,Y] = meshgrid(1:1:l, h:-1:1);

%% interpulations
% interpulate U and V from u and v for the whole image
Q = griddata(x,y,Lables,X,Y,'v4');

% Q = scatteredInterpolant(x,y,Lables,'natural');
% Q = Q(X,Y);

%% Filters
% if min(min(Q))<0
%     Q=Q-min(min(Q));
% end
% if max(max(Q))>1
%     Q=Q/max(max(Q)); 
% end
% Q=Q.^2; %inensefy the image -<shold be chossen by the user
% 
% 
% if min(min(Q))<0
%     Q=Q-min(min(Q));
% end
% if max(max(Q))>1
%     Q=Q/max(max(Q)); 
% end
%Q= filter2([ 1 0],Q,'full')
windowSize = round(min(h,l)/8);
b = (1/windowSize)*ones(1,windowSize);
a = 1;
% %Q = filter(b,a,Q);
zi=(1/windowSize)*ones(1,windowSize-1);
%Q = filter(b,a,Q,zi,2);
 H=(1/windowSize)*ones(windowSize,windowSize);
 %Q = filter2(H,Q);
 %Q = movmedian(Q,windowSize);
 Q=smoothdata(Q,'sgolay',windowSize);

%% normalize Q between 0 and 1

if min(min(Q))<0
    Q=Q-min(min(Q));
end
if max(max(Q))>1
    Q=Q/max(max(Q)); 
end

%% Crop map
B = flipud(CroppedMask);
Q(B)=5;
Q=Q*(-1)+1;
%%
% This part plots the image and the streamlines on top of each other
%initialize figure

if ~exist('dontplot')
    figure(5)
    hold on
    ax=gca;
    fig=gcf;
    fig.Position=[ 100 100 l h];
    imagepos=[0 0 1 1];
    %show map
    axes('pos',imagepos)
    contourf(Q,[0:0.1:1],'LineStyle','none');
    axis equal

    %show image with alpha mask
    axes('pos',imagepos)
    imshow(I)
    alpha 0.4
    delete(ax)
    hold off
    end
end

