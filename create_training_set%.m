function [trainingSet,tuftLabel,Orientations]=create_training_set_main(labeled,bw)

graindata = regionprops(labeled,'basic');

len=length(graindata);
xcenter=zeros(len,1);ycenter=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    xcenter(i)=Center(1); ycenter(i)=Center(2);
end
global val;
val=[];
choose_tufts_for_ML(bw,xcenter,ycenter,graindata)
uiwait (gcf)
x_point=val.x;
[x_point,ia,ic] = unique(x_point,'last')
y_point=val.y(ia);
labels=val.label(ia);
tuft=val.tufts(ia);
box=val.box(ia,:)
val=[]; clear val;
[h,l]=size(bw);

imshow(bw)
hold on
title('Choose segments representing attached flow','FontSize',16,'Color',[0,0,0]);
hold off
[x_point,y_point] = getpts;
close
attached_tufts=zeros(length(x_point),1);
attached_tufts(:,2)=1;
for i=1:length(x_point)
    [Min_Dis,attached_tufts(i,1)]=min(pdist2([x_point(i) y_point(i)],[xcenter ycenter]));
end

imshow(bw)
hold on
title('Choose segments representing UN-attached flow','FontSize',16,'Color',[0,0,0]);
hold off
[x_point,y_point] = getpts;
close
unattached_tufts=zeros(length(x_point),2);
unattached_tufts(:,2)=0;
for i=1:length(x_point)
    [Min_Dis,unattached_tufts(i,1)]=min(pdist2([x_point(i) y_point(i)],[xcenter ycenter]));
end

MinorAxisLength=regionprops(labeled,'MinorAxisLength');
MajorAxisLength=regionprops(labeled,'MajorAxisLength');
Orientations=regionprops(labeled,'Orientation');
%windangle=0;
for i=1:length(xcenter)
    trainingSet(i).pixelX=xcenter(i)/l; trainingSet(i).pixelY=ycenter(i)/h;

    trainingSet(i).straightness=(1-MinorAxisLength(i).MinorAxisLength...
        /MajorAxisLength(i).MajorAxisLength);
end
tuftLabel=[attached_tufts;unattached_tufts];

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


end

