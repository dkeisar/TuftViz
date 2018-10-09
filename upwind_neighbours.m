function neighboor = upwind_neighbours(trainingSet,WindAngle)
%function smoothen the data based on the tufts above it
%Wind angle must come here in angles not in rads
%Cent(:,2)=max(Cent(:,2))-Cent(:,2);
for i=1:length(trainingSet)
    Cent(i,1)=trainingSet(i).pixelX;
    Cent(i,2)=trainingSet(i).pixelY;
end
if (WindAngle>=0 && WindAngle<45) || (WindAngle>315 && WindAngle<=360)
    [sortcent,indd]=sortrows(Cent,1,'ascend');%sortcent=A(indd,:)
elseif (WindAngle>=45 && WindAngle<135)
    [sortcent,indd]=sortrows(Cent,2,'ascend');%sortcent=A(indd,:)
elseif (WindAngle>=135 && WindAngle<225)
    [sortcent,indd]=sortrows(Cent,1,'descend');%sortcent=A(indd,:)
elseif (WindAngle>=225 && WindAngle<315)
    [sortcent,indd]=sortrows(Cent,2,'descend');%sortcent=A(indd,:)
end
for i=1:length(sortcent)
    counter=1;
    for j=1:length(Cent)
        angleToTheTuft=rad2deg(atan2(Cent(j,2)-sortcent(i,2),...
            Cent(j,1)-sortcent(i,1)));
        if angleToTheTuft<0
            angleToTheTuft=angleToTheTuft+360;
        end
        %figure (4)
        %hold on
        %text (sortcent(i,1),sortcent(i,2), num2str(indd(i)));
        if (angleToTheTuft>=WindAngle-60 && angleToTheTuft<=WindAngle+60) ||...
                (angleToTheTuft>=WindAngle-360-60 && angleToTheTuft<=WindAngle-360+60) ||...
                (angleToTheTuft>=WindAngle+360-60 && angleToTheTuft<=WindAngle+360+60)
            tuftbef(counter,1:2)=Cent(j,:);
            tuftbef(counter,3)=j;
            counter=counter+1;
            %text (Cent(j,1),Cent(j,2), [num2str(j),'-',num2str(angleToTheTuft),'-Yes']);
        else
            %text (Cent(j,1),Cent(j,2), [num2str(j),'-',num2str(angleToTheTuft),'-No']);
        end
        %hold off
    end
    try [D,in]=pdist2([tuftbef(:,1),tuftbef(:,2)]...
            ,[sortcent(i,1),sortcent(i,2)],'euclidean','Smallest',4);
    end
     for k=1:4
        try
            neighboor(indd(i),k)=tuftbef(in(k),3);
        catch
            neighboor(indd(i),k)=0;
        end
    end
%     for k=1:4
%         try
%             [D,ini]=pdist2([Cent(:,1),Cent(:,2)]...
%                 ,[tuftbef(in(k),1),tuftbef(in(k),2)],'euclidean','Smallest',1);
%             if D<0.01
%                 neighboor(i,k)=ini;
%             end
%         catch
%             neighboor(i,k)=0;
%         end
%     end
    try clear ('tuftbef','in')
    end
end

end



