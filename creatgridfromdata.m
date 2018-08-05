function [gridedimage] = creatgridfromdata(graindata,gridedindex)
stdX=0; stdY=0;
    for i=1:size(gridedindex,1)
        for j=1:size(gridedindex,2)
            X(j)=graindata(gridedindex(i,j)).Centroid(1);
            Y(j)=graindata(gridedindex(i,j)).Centroid(2);
        end
        stdX=[stdX,std(X)];stdY=[stdY,std(Y)];
    end
    stdX=mean(stdX);stdY=mean(stdY);
    if stdY>stdX
        for i=1:size(gridedindex,1)
            for j=1:size(gridedindex,2)
                gridedimage(j,i).X=graindata(gridedindex(i,j)).Centroid(1);
                gridedimage(j,i).Y=graindata(gridedindex(i,j)).Centroid(2);
            end
        end
    else
        for i=1:size(gridedindex,1)
            for j=1:size(gridedindex,2)
                gridedimage(i,j).X=graindata(gridedindex(i,j)).Centroid(1);
                gridedimage(i,j).Y=graindata(gridedindex(i,j)).Centroid(2);
            end
        end
    end
    
end

