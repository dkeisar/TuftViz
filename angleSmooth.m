function edgeangle = angleSmooth(edgeangle,Cent,WindAngle)
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
sortedgeangle=edgeangle(indd);
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
            tuftbefedgeangle(counter)=edgeangle(j);
            counter=counter+1;
        end
    end
    try [D,in]=pdist2([tuftbef(:,1),tuftbef(:,2)]...
            ,[sortcent(i,1),sortcent(i,2)],'euclidean','Smallest',2);
    end
    
    try tuftBefMat(1)=tuftbefedgeangle(in(1));
    end
    try tuftBefMat(2)=tuftbefedgeangle(in(2));
        number2=1;% see ifthere is seconed neighboor for the mean part below
    end
    try meanAboveAngle=mean(tuftBefMat);
    end
    try if abs(sortedgeangle(i)-meanAboveAngle)>45 
            if exist('number2') && abs(tuftBefMat(2)-tuftBefMat(1))>60
                if abs(sortedgeangle(i)-tuftBefMat(1))>abs(sortedgeangle(i)-tuftBefMat(2))
                    sortedgeangle(i)=mean([tuftBefMat(2),sortedgeangle(i)]);
                else
                    sortedgeangle(i)=mean([tuftBefMat(1),sortedgeangle(i)]);
                end
            else
                sortedgeangle(i)=mean([meanAboveAngle,meanAboveAngle,sortedgeangle(i)]);
            end
        end
    end
    try clear ('tuftbef','meanAboveAngle','tuftBefMat','in','tuftbefedgeangle');
        clear ('number2');
    end
end

for i=1:length(indd)
    Cent(indd(i))=sortcent(i);
    edgeangle(indd(i))=sortedgeangle(i);
end
end



