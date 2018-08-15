function [tuftSet,labeledTufts] = clusterStepOne(bw,labeled,I,imageTune,useHybryd)
WindAngle=imageTune.FlowAngle;
%% main clustering func
%% choose rand image then segment and tune it
WindAngle=deg2rad(WindAngle);
[h,l]=size(bw);
[tuftSet,xcenter,ycenter,graindata]=create_tuft_set(labeled,bw,WindAngle);

global MLhandel
%clusterGrid=[];
%graindata = regionprops(labeled,'basic');
%create_grid_for_clustering(I,bw,graindata)
%     uiwait(gcf)
try
    gridedindex = MLhandel.clusterGrid.gridindex;
catch
    load('clusterGrid_for_christ_mov.mat')
    gridedindex=clusterGrid.gridindex;
end
[gridedTufts] = creatgridfromdata(graindata,gridedindex);
%%buildGridTrainingSet
trainingSetSize = size(gridedTufts);
trainingSet = zeros(trainingSetSize(1), trainingSetSize(2),10);% 1 is the lengt of the data
for i = 1:trainingSetSize(1)
    for j = 1:trainingSetSize(2)
        [data, valid] = getTuftDataByCentroid(tuftSet, gridedTufts(i,j), h, l,WindAngle);
        if(valid)
            trainingSet(i,j,:) = data;
        end
    end
end
%%
%clusterGrid=[];

labelDistanceFactor = 4;
[labeledTufts] = calcCluster(trainingSet,h,l, MLhandel.noMaxCluster, labelDistanceFactor, useHybryd);

%%


end



