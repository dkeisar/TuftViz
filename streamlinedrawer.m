function streamlinedrawer(graindata,graindata_Orientation,CroppedMask,CropFrame,Mask,FlowAngle,I,Flip)
%%
% This function gets data on the labled tuft, and draws streamlines on
% the image.
% -graindata:               Contains the centroids of the labled data
% -graindata_Orientation:   The orientation of the labled data in degrees
%                           as respect to the x-axis
% -CroppedMask:             The Mask that was chosen for the image by the
%                           user or by the algorithm
% -I:                       The masked image before the segmentation
%                           prosses
%%
% This part classifies the labled data to x,y,u,v vectors
% u and v are just the diraction of the labled tufts

len=length(graindata);
x=zeros(len,1);y=zeros(len,1);Orientation=zeros(len,1);     %initialize
u=zeros(len,1);v=zeros(len,1);                              %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    if graindata_Orientation(i).Orientation>=0
        Orientation_cos(i)=graindata_Orientation(i).Orientation;
        
    else
        Orientation_cos(i)=graindata_Orientation(i).Orientation+180;
    end
    Orientation(i)=graindata_Orientation(i).Orientation;
    Area=graindata(i).Area;
    lengng=graindata(i).BoundingBox(3);
    %classify to the x and y location
    x(i)=Center(1); y(i)=Center(2);
    
    %diraction in x(u) and y(v) of the tufts
    u(i)=cos(deg2rad(graindata_Orientation(i).Orientation));
    v(i)=sin(deg2rad(graindata_Orientation(i).Orientation));
end

%%
% This part classifies the labled data to X,Y,U,V grid by interpulating
% the x,y,u,v data (v4-exect solution) for all the X,Y grid
% U and V are just the diraction grid of the labled tufts

x=round(x);y=round(y);      %round to the nearest pixle of the labeled data
% meshgrid X and Y to the size of image
[h,l]=size(I);
[X,Y] = meshgrid(1:1:l, h:-1:1);
Y=flipud(Y); X=flipud(X);
% interpulate U and V from u and v for the whole image
% U = griddata(x,y,cos(deg2rad(Orientation)),X,Y,'v4');
% V = griddata(x,y,(sin(deg2rad(Orientation))),X,Y,'v4');
Ua = scatteredInterpolant(x,y,cos(deg2rad(Orientation)),'natural');
U = Ua(X,Y);
Va = scatteredInterpolant(x,y,sin(deg2rad(Orientation)),'natural');
V = Va(X,Y);
try
    if FlowAngle>=135&& FlowAngle<=225
        U=-U;   
        V=-V;
    elseif FlowAngle>=225&& FlowAngle<=315
        %U = griddata(x,y,-cos(deg2rad(Orientation_cos)),X,Y,'v4');
        Ua = scatteredInterpolant(x,y,-cos(deg2rad(Orientation_cos')),'natural');
        U = Ua(X,Y);
        Va = scatteredInterpolant(x,y,-abs(sin(deg2rad(Orientation))),'natural');
        V = Va(X,Y);
    elseif FlowAngle>=45&& FlowAngle<=135
        %U = griddata(x,y,cos(deg2rad(Orientation_cos)),X,Y,'v4');
        Ua = scatteredInterpolant(x,y,cos(deg2rad(Orientation_cos')),'natural');
        U = Ua(X,Y);
        Va = scatteredInterpolant(x,y,abs(sin(deg2rad(Orientation))),'natural');
        V = Va(X,Y);
    end
end
U=flipud(U); V=flipud(V);

%U=U-min(min(U));U=U/max(max(U)); %normalize U between 0 and 1
%V=V-min(min(V));V=V/max(max(V)); %normalize V between 0 and 1

%U=U.^3;V=V.^3;%inensefy the image -<shold be chossen by the user
% Mask U and V to the area of interest
B = flipud(CroppedMask);
U(B)=0;
V(B)=0;
NoOfStream=200;
% for i=1:NoOfStream
%     startx(i)=2*i;
%     starty(i)=h*i/(NoOfStream+1)
% end
% for i=1:NoOfStream
%     startx(i+NoOfStream)=l-150;
%     starty(i+NoOfStream)=h*i/(NoOfStream+1);
% end
Z=contour(flipud(CroppedMask),1);
close

%%
% This part plots the image and the streamlines on top of each other
%initialize figure

% get streamline start
% axes('pos',imagepos)
% imshow(I)
% alpha 0.4
% startx = 0; starty = 0;
%[startx,starty] = getpts;
close
% startx = l-(startx);
% starty = h-(starty);
%plot streamlines
figure(2)
hold on
fig=gcf;
ax=gca;
%fig.Position=[100 100 l h];
imagepos=[0 0 1 1];
axes('Position',imagepos);
streamline(X,Y,U,V,[Z(1,1:10:length(Z))],[Z(2,1:10:length(Z))]);
%streamslice(U,V,'linear','noarrows')
%quiver(x,y,u,v)
axis equal
%show image with alpha mask
axes('Position',imagepos)
imshow(I)
alpha 0.4

%%
%for testing

%quiver(x,y,u,v);
% [curlz,cav]= curl(X,Y,U,V);
% contourf(curlz,'LineStyle','none');
hold off
end

