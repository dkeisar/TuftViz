function neighboor = upwind_neighbours(Cent,WindAngle)
%function smoothen the data based on the tufts above it
%Wind angle must come here in angles not in rads
%Cent(:,2)=max(Cent(:,2))-Cent(:,2);

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
        if (angleToTheTuft>=WindAngle-60 && angleToTheTuft<=WindAngle+60) ||...
                (angleToTheTuft>=WindAngle-360-60 && angleToTheTuft<=WindAngle-360+60) ||...
                (angleToTheTuft>=WindAngle+360-60 && angleToTheTuft<=WindAngle+360+60)
            tuftbef(counter,:)=Cent(j,:);
            counter=counter+1;
        end
    end
    try [D,in]=pdist2([tuftbef(:,1),tuftbef(:,2)]...
            ,[sortcent(i,1),sortcent(i,2)],'euclidean','Smallest',4);
    end
    for k=1:4
        try
            [D,ini]=pdist2([Cent(:,1),Cent(:,2)]...
                ,[tuftbef(in(k),1),tuftbef(in(k),2)],'euclidean','Smallest',1);
            if D<0.01
                neighboor(i,k)=ini;
            end
        catch
            neighboor(i,k)=0;
        end
    end
    try clear ('tuftbef','in','ini')
    end
end

end



