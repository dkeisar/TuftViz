function find_pressed_segments(graindata,bw)


% This part classifies the labled data to x,y vectors

len=length(graindata);
x=zeros(len,1);y=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    x(i)=Center(1); y(i)=Center(2);
end

imshow(bw)
hold on
title('Choose segments representing attached flow','FontSize',16,'Color',[0,0,0]);
hold off

[x_point,y_point] = getpts
close
Min_Dis=100000000000; Min_points=zeros(length(x_point),1)
for i=1:length(x_point)
    for j=1:length(x)
        Dis=pdist2([x_point(i) y_point(i)],[x(j) y(j)]);
        if Dis<Min_Dis
            Min_Dis=Dis;
            Min_points(i)=j
        end
    end
    Min_Dis=100000000000;
    
end

end

