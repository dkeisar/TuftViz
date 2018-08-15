function [x,y,u,v,X,Y,U,V,Z,Zind] = streamline_drawer_ML...
    (tuftSet,CroppedMask,I,bw,WindAngle,noRowsOfStreamlines,distance,flipup,flipside)
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
f = uifigure;
d = uiprogressdlg(f,'Title','Computing',...
    'Indeterminate','on');
%%
% This part classifies the labled data to x,y,u,v vectors
% u and v are just the diraction of the labled tufts
len=length(tuftSet);
[h,l]=size(bw);
x=zeros(len+4,1);y=zeros(len+4,1);Orientation=zeros(len,1);     %initialize
u=zeros(len+4,1);v=zeros(len+4,1);                              %initialize
for i=1:len
    angle(i)=tuftSet(i).edgeRelatedrealAngle;
    if angle(i)>=0
        angle_cos(i)=angle(i);
        
    else
        angle_cos(i)=angle(i)+180;
    end
    
    %diraction in x(u) and y(v) of the tufts
    u(i)=cos(deg2rad(angle(i)));
    v(i)=sin(deg2rad(angle(i)));
    x(i)=tuftSet(i).pixelX*l; y(i)=h-tuftSet(i).pixelY*h;
end
x(i+1)=0; y(i+1)=0; x(i+2)=l; y(i+2)=0;
x(i+3)=0; y(i+3)=h; x(i+4)=l; y(i+4)=h;
[~,ind]=min(pdist2([0 0] ,[x y]));u(i+1)=u(ind);v(i+1)=v(ind);
[~,ind]=min(pdist2([0 h] ,[x y]));u(i+2)=u(ind);v(i+2)=v(ind);
[~,ind]=min(pdist2([l 0] ,[x y]));u(i+3)=u(ind);v(i+3)=v(ind);
[~,ind]=min(pdist2([l h] ,[x y]));u(i+4)=u(ind);v(i+4)=v(ind);

angle(i+1:i+4)=0.0001;

%%
% This part classifies the labled data to X,Y,U,V grid by interpulating
% the x,y,u,v data (v4-exect solution) for all the X,Y grid
% U and V are just the diraction grid of the labled tufts

x=round(x);y=round(y);      %round to the nearest pixle of the labeled data
% meshgrid X and Y to the size of image
[X,Y] = meshgrid(1:1:l, h:-1:1);
Y=flipud(Y); X=flipud(X);
% interpulate U and V from u and v for the whole image
U = griddata(x,y,u',X,Y,'v4');
V = griddata(x,y,v',X,Y,'v4');
% Ua = scatteredInterpolant(x,y,cos(deg2rad(angle')),'natural');
% U = Ua(X,Y);
% Va = scatteredInterpolant(x,y,sin(deg2rad(angle')),'natural');
% V = Va(X,Y);

U=flipud(U); V=flipud(V);
if exist('Flip')
    U=flipud(U);
end

%U=U-min(min(U));U=U/max(max(U)); %normalize U between 0 and 1
%V=V-min(min(V));V=V/max(max(V)); %normalize V between 0 and 1

%U=U.^3;V=V.^3;%inensefy the image -<shold be chossen by the user
% Mask U and V to the area of interest

B = flipud(CroppedMask);

% U(B)=0;
% V(B)=0;
V=-V;
%% this part decide on the begining of the stramlines
minX=min(x); maxX=max(x);   L=maxX-minX+1;
minY=min(y); maxY=max(y);   H=maxY-minY+1;
 minX=round(min(x)+L/30); maxX=round(max(x)-L/30);   L=maxX-minX+1;
 minY=round(min(y)+H/30); maxY=round(max(y)-H/30);   H=maxY-minY+1;
Numb=noRowsOfStreamlines;
if flipup==1 || flipside==1
    WindAngle=WindAngle+180;
    if WindAngle>=360
        WindAngle=WindAngle-360
    end
end
try
    for i=1:Numb
        if (WindAngle>=135 && WindAngle<225)
            Z(((i-1)*H+1):i*H,1)=maxX*(1-(i-1)/(Numb+2));      Z(((i-1)*H+1):i*H,2)=minY:maxY;
        elseif (WindAngle>=225 && WindAngle<315)
            Z(((i-1)*L+1):i*L,1)=minX:maxX;          Z(((i-1)*L+1):i*L,2)=maxY-(maxY-minY)*(1-(i-1)/(Numb+2));
        elseif (WindAngle>=0 && WindAngle<45) || (WindAngle>315 && WindAngle<=360)
            Z(((i-1)*H+1):i*H,1)=maxX-(maxX-minX)*(1-(i-1)/(Numb+2));      Z(((i-1)*H+1):i*H,2)=minY:maxY;
        elseif (WindAngle>=45 && WindAngle<135)
            Z(((i-1)*L+1):i*L,1)=minX:maxX;          Z(((i-1)*L+1):i*L,2)=maxY*(1-(i-1)/(Numb+2));
        end
    end
catch
    i=1;numb=1;
    if (WindAngle>=135 && WindAngle<225)
        Z(((i-1)*H+1):i*H,1)=maxX*(1-(i-1)/(Numb+2));      Z(((i-1)*H+1):i*H,2)=minY:maxY;
    elseif (WindAngle>=225 && WindAngle<315)
        Z(((i-1)*L+1):i*L,1)=minX:maxX;          Z(((i-1)*L+1):i*L,2)=maxY-(maxY-minY)*(1-(i-1)/(Numb+2));
    elseif (WindAngle>=0 && WindAngle<45) || (WindAngle>315 && WindAngle<=360)
        Z(((i-1)*H+1):i*H,1)=maxX-(maxX-minX)*(1-(i-1)/(Numb+2));      Z(((i-1)*H+1):i*H,2)=minY:maxY;
    elseif (WindAngle>=45 && WindAngle<135)
        Z(((i-1)*L+1):i*L,1)=minX:maxX;          Z(((i-1)*L+1):i*L,2)=maxY*(1-(i-1)/(Numb+2));
    end
end
if (WindAngle>=135 && WindAngle<225)
    Z(Numb*H+1:Numb*H+L,1)=minX:maxX          ;Z(Numb*H+1:Numb*H+L,2)=minY;
    Z(Numb*H+L+1:Numb*H+2*L,1)=minX:maxX      ;Z(Numb*H+L+1:Numb*H+2*L,2)=maxY;
    y1=1:distance:Numb*H; y2=Numb*H+1:2*distance:Numb*H+2*L; Zind=[y1,y2];
elseif (WindAngle>=225 && WindAngle<315)
    Z(Numb*L+1:H+Numb*L,1)=minX               ;Z(Numb*L+1:H+Numb*L,2)=minY:maxY;
    Z(H+Numb*L+1:2*H+Numb*L,1)=maxX           ;Z(H+Numb*L+1:2*H+Numb*L,2)=minY:maxY;
    y1=1:distance:Numb*L; y2=Numb*L+1:2*distance:2*H+Numb*L; Zind=[y1,y2];
elseif (WindAngle>=0 && WindAngle<45) || (WindAngle>315 && WindAngle<=360)
    Z(Numb*H+1:Numb*H+L,1)=minX:maxX          ;Z(Numb*H+1:Numb*H+L,2)=minY;
    Z(Numb*H+L+1:Numb*H+2*L,1)=minX:maxX      ;Z(Numb*H+L+1:Numb*H+2*L,2)=maxY;
    y1=1:distance:Numb*H; y2=Numb*H+1:2*distance:Numb*H+2*L; Zind=[y1,y2];
elseif (WindAngle>=45 && WindAngle<135)
    Z(Numb*L+1:H+Numb*L,1)=minX               ;Z(Numb*L+1:H+Numb*L,2)=minY:maxY;
    Z(H+Numb*L+1:2*H+Numb*L,1)=maxX           ;Z(H+Numb*L+1:2*H+Numb*L,2)=minY:maxY;
    y1=1:distance:Numb*L; y2=Numb*L+1:2*distance:2*H+Numb*L; Zind=[y1,y2];
end
if flipup==1 || flipside==1
    WindAngle=WindAngle-180;
    if WindAngle<0
        WindAngle=WindAngle+360
    end
end
%%s
% This part plots the image and the streamlines on top of each other
%initialize figure


% figure(2)
% hold on
% fig=gcf;
% ax=gca;
% %fig.Position=[100 100 l h];
% imagepos=[0 0 1 1];
% axes('Position',imagepos);
% streamline(X,Y,U,V,Z(Zind,1), Z(Zind,2));
% %streamline(X,Y,U,V,[Ztag(1,1:10:length(Ztag))],[Ztag(2,1:10:length(Ztag))]);
% %streamslice(U,V,'cubic','noarrows')
% %quiver(x,y,u,v)
% axis equal
% % axes('Position',imagepos);
% % scatter(x,y)
% % axis equal
% % text(x,y,string(angle))
%
% %show image with alpha mask
% axes('Position',imagepos)
% imshow(I)
% alpha 0.4

%%
%for testing

%quiver(x,y,u,v);
% [curlz,cav]= curl(X,Y,U,V);
% contourf(curlz,'LineStyle','none');
hold off
close(f);
end

