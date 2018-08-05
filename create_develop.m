function [trainingSet,Orientations]=create_develop(seglabeled,bw,WindAngle,trainingmat,weightVector,CroppedMask,I)

graindata = regionprops(seglabeled,'basic');

len=length(graindata);
xcenter=zeros(len,1);ycenter=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    xcenter(i)=Center(1); ycenter(i)=Center(2);
end

choose_tufts_for_develop(bw,xcenter,ycenter,graindata,trainingmat,weightVector,CroppedMask,I)
uiwait (gcf)

[h,l]=size(bw);

MinorAxisLength=regionprops(seglabeled,'MinorAxisLength');
MajorAxisLength=regionprops(seglabeled,'MajorAxisLength');
Orientations=regionprops(seglabeled,'Orientation');

trainingSet.length=MajorAxisLength;

for i=1:length(xcenter)
    trainingSet(i).pixelX=xcenter(i)/l; trainingSet(i).pixelY=ycenter(i)/h;
    trainingSet(i).straightness=(1-MinorAxisLength(i).MinorAxisLength...
        /MajorAxisLength(i).MajorAxisLength);
end

Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
for i=1:length(xcenter)
    for j=1:length(xcenter)
        if i~=j
            Dis=pdist2([xcenter(i) ycenter(i)],[xcenter(j) ycenter(j)]);
            if Dis<Min_Dis_1
                Min_Dis_1=Dis;
                trainingSet(i).neighbor_1=j;
            elseif Dis<Min_Dis_2
                Min_Dis_2=Dis;
                trainingSet(i).neighbor_2=j;
            elseif Dis<Min_Dis_3
                Min_Dis_3=Dis;
                trainingSet(i).neighbor_3=j;
            elseif Dis<Min_Dis_4
                Min_Dis_4=Dis;
                trainingSet(i).neighbor_4=j;
            end
        end
    end
    Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
end
%% calculate angle of the second half of the tuft
% image= regionprops(seglabeled,'Image');

% for i=1:length(xcenter)
%    [h,l]=size(image(i));
%    relativearealength=l/abs(cos(WindAngle))
%    
% end
end

