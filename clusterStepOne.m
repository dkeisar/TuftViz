function [tuftSet,labeledTufts] = clusterStepOne(bw,labeled,I,imageTune,useHybryd)
WindAngle=imageTune.FlowAngle;
%% main clustering func
%% choose rand image then segment and tune it
WindAngle=deg2rad(WindAngle);
[h,l]=size(bw);
[tuftSet,xcenter,ycenter,graindata]=create_tuft_set(labeled,bw,WindAngle);

global MLhandel
try
    generalgridedindex = MLhandel.gridindex;
    gridindexY=MLhandel.gridindexY;
    gridindexX=MLhandel.gridindexX;
    labelDistanceFactor = 20;
    noOfSuperPixels=MLhandel.noMaxCluster;
    MLhandel.minNumInCluster
catch
    load('clusterGrid_for_christmov.mat')
    generalgridedindex=gridindex;
    MLhandel.noMaxCluster=20;
    labelDistanceFactor = 20;
    noOfSuperPixels=20;
end
gridedindex=generalgridedindex;
for i=1:size(generalgridedindex,1)
    for j=1:size(generalgridedindex,2)
        min=inf;
        gridedindex(i,j)=0;
        for k=1:length(graindata)
            if min>=(abs(gridindexX(i,j)-graindata(k).Centroid(1))...
                    + abs(gridindexY(i,j)-graindata(k).Centroid(2)))
                min=(abs(gridindexX(i,j)-graindata(k).Centroid(1))...
                    + abs(gridindexY(i,j)-graindata(k).Centroid(2)));
                gridedindex(i,j)=k;
            end
        end    
    end
end
%%%%% code to make gridindex match the graindata!!!
[gridedTufts] = creatgridfromdata(graindata,gridedindex);

%%buildGridTrainingSet
trainingSetSize = size(gridedTufts);
trainingSet = zeros(trainingSetSize(1), trainingSetSize(2),10);% 1 is the lengt of the data
counter=1;
for i = 1:trainingSetSize(1)
    for j = 1:trainingSetSize(2)
        try [data, valid] = getTuftDataByCentroid(tuftSet, gridedTufts(i,j), h, l,WindAngle);
        if(valid)
            trainingSet(i,j,:) = data;
            forScatter(counter,1)=trainingSet(i,j,1);
            forScatter(counter,2)=trainingSet(i,j,2);
            forScatter(counter,3)=i;
            forScatter(counter,4)=j;
            counter=counter+1;
        end
        end
    end
end
%%
%clusterGrid=[];
figure(3);
hold on
axis ([0 l 0 h])

for i=1:length(forScatter)
    text (forScatter(i,1)*l,forScatter(i,2)*h,[num2str(forScatter(i,3)),'-',num2str(forScatter(i,4))]);
end
hold off
[labeledTufts] = calcCluster(trainingSet,h,l, MLhandel.noMaxCluster,noOfSuperPixels,labelDistanceFactor, useHybryd,bw);
%[labeledTufts] = calcClusters(trainingSet,h,l, MLhandel.noMaxCluster,noOfSuperPixels ,labelDistanceFactor, useHybryd);

%%


end



