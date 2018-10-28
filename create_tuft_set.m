function [trainingSet,xcenter,ycenter,graindata]=create_tuft_set(labeled,bw,WindAngle)

graindata = regionprops(labeled,'basic');

len=length(graindata);
xcenter=zeros(len,1);ycenter=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    xcenter(i)=Center(1); ycenter(i)=Center(2);
end
[h,l]=size(bw);

MinorAxisLength=regionprops(labeled,'MinorAxisLength');
MajorAxisLength=regionprops(labeled,'MajorAxisLength');
Orientations=regionprops(labeled,'Orientation');
trainingSet.length=MajorAxisLength;
pixellist=regionprops(labeled,'PixelList');
Centroid=regionprops(labeled,'Centroid');
for i=1:length(xcenter)
    Length(i)=MajorAxisLength(i).MajorAxisLength;
end
maxLength=max(Length);
WindAngle=rad2deg(WindAngle);
for i=1:length(xcenter)
    trainingSet(i).pixelX=xcenter(i)/l; trainingSet(i).pixelY=ycenter(i)/h;
    trainingSet(i).straightness=(1-MinorAxisLength(i).MinorAxisLength...
        /MajorAxisLength(i).MajorAxisLength);
    
    trainingSet(i).length=Length(i)/maxLength;
    
    [Cent(i,1:2),edgeangle(i)] = edgeangleCalculation(trainingSet,pixellist,Centroid...
        ,MajorAxisLength,Orientations,WindAngle,i);
    
    %     trainingSet(i).edgeRelatedrealAngle=edgeangle(i);
    %
    %     trainingSet(i).edgeRelatedAngle=abs(cos(deg2rad(WindAngle-trainingSet(i).edgeRelatedrealAngle)));
end
edgeangle = angleSmooth(edgeangle,Cent,WindAngle);

for i=1:length(xcenter)
    trainingSet(i).edgeRelatedrealAngle=edgeangle(i);
    
    trainingSet(i).edgeRelatedAngle=abs(cos(deg2rad(WindAngle-trainingSet(i).edgeRelatedrealAngle)));
end
for i=1:length(Orientations)
    trainingSet(i).windRelatedAngle=abs(cos(deg2rad((WindAngle-...
        Orientations(i).Orientation))));
end
neighboor = upwind_neighbours(trainingSet,WindAngle);
for i=1:length(xcenter)
    trainingSet(i).neighbor_1=neighboor(i,1);
    trainingSet(i).neighbor_2=neighboor(i,2);
    trainingSet(i).neighbor_3=neighboor(i,3);
    trainingSet(i).neighbor_4=neighboor(i,4);
%     figure (5)
%     hold on
%     text (trainingSet(i).pixelX,trainingSet(i).pixelY, num2str(i));
%     try  text (trainingSet(neighboor(i,1)).pixelX,trainingSet(neighboor(i,1)).pixelY, ['N1-',num2str(neighboor(i,1))]);
%     end
%     try text (trainingSet(neighboor(i,2)).pixelX,trainingSet(neighboor(i,2)).pixelY, ['N2-',num2str(neighboor(i,2))]);
%     end
%     try text (trainingSet(neighboor(i,3)).pixelX,trainingSet(neighboor(i,3)).pixelY, ['N3-',num2str(neighboor(i,3))]);
%     end
%     try text (trainingSet(neighboor(i,4)).pixelX,trainingSet(neighboor(i,4)).pixelY, ['N4-',num2str(neighboor(i,4))]);
%     end
%     hold off
end


% Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
% for i=1:length(xcenter)
%     for j=1:length(xcenter)
%         if i~=j
%             Dis=pdist2([xcenter(i) ycenter(i)],[xcenter(j) ycenter(j)]);
%             if Dis<Min_Dis_1
%                 Min_Dis_1=Dis;
%                 trainingSet(i).neighbor_1=j;
%             elseif Dis<Min_Dis_2
%                 Min_Dis_2=Dis;
%                 trainingSet(i).neighbor_2=j;
%             elseif Dis<Min_Dis_3
%                 Min_Dis_3=Dis;
%                 trainingSet(i).neighbor_3=j;
%             elseif Dis<Min_Dis_4
%                 Min_Dis_4=Dis;
%                 trainingSet(i).neighbor_4=j;
%             end
%         end
%     end
%     Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
% end

% image= regionprops(labeled,'Image');
%% calculate angle of the second half of the tuft
% for i=1:length(xcenter)
%    [h,l]=size(image(i));
%    relativearealength=l/abs(cos(WindAngle))
%
% end
end

