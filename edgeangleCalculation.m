function [Cent,edgeangle] = edgeangleCalculation(trainingSet,pixellist,Centroid...
        ,MajorAxisLength,Orientations,WindAngle,i)
	%%find edge angle
    p = polyfit(pixellist(i).PixelList(:,1),pixellist(i).PixelList(:,2), 7);
    Cent(1:2)=Centroid(i).Centroid;
    %[~,m,~] = regression(pixellist(i).PixelList(:,1),pixellist(i).PixelList(:,2));
    
    
    %for regular tafts
    [~,ind]=min(pdist2([(Cent(1)+MajorAxisLength(i).MajorAxisLength*cos(deg2rad(WindAngle))), ...
        (Cent(2)-MajorAxisLength(i).MajorAxisLength*sin(deg2rad(WindAngle)))]...
        ,[pixellist(i).PixelList(:,1),pixellist(i).PixelList(:,2)]));
    % for tufts with doted sticker
    %[~,ind]=max(pdist2([Cent(i,1),Cent(i,2)],pixellist(i).PixelList(:,1:2)));
    
    k = polyder(p);
    ytag = polyval(k,pixellist(i).PixelList(ind,1));
    edgeangle=rad2deg(atan(ytag));
    %edgeangle = rad2deg(atan(m(ind)));
    Orientation=Orientations(i).Orientation;
    if edgeangle<0
        edgeangle=edgeangle+360;
    end
    if Orientation<0
        Orientation=Orientation+360;
    end
    if abs(WindAngle-edgeangle)>90 && abs(WindAngle-edgeangle)<270
        %         ~(edgeangle<WindAngle+90 && edgeangle>WindAngle-90)
        edgeangle=edgeangle+180;
    end
    if abs(WindAngle-Orientation)>90 && abs(WindAngle-Orientation)<270
        %         ~(edgeangle<WindAngle+90 && edgeangle>WindAngle-90)
        Orientation=Orientation+180;
    end
    
    if ~((edgeangle<WindAngle && WindAngle<Orientation) ...
            || (edgeangle>WindAngle && WindAngle>Orientation))
        if abs(Orientation-edgeangle)>45
            edgeangle=Orientation;
        end
    else
        edgeangle=Orientation;
    end
    %     check place
    %     figure(1)
    %     scatter(pixellist(i).PixelList(:,1),h-pixellist(i).PixelList(:,2))
    %     text(pixellist(i).PixelList(ind,1),h-pixellist(i).PixelList(ind,2),string(edgeangle))
    edgeangle=Orientation;
    edgeangle=edgeangle-(WindAngle-edgeangle)*(1/trainingSet(i).straightness-1);
    while ~(edgeangle>=0 && edgeangle<=360)
        if edgeangle>360
            edgeangle=edgeangle-360;
        end
        if edgeangle<0
            edgeangle=edgeangle+360;
        end
    end
    
    
end

