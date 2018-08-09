function [tuftSet,labeledTufts] = clusterStepOne(bw,labeled,I, useUnsupervised)
WindAngle=imageTune.FlowAngle;
%% main clustering func
    %% choose rand image then segment and tune it
    [h,l]=size(bw);
    [tuftSet,xcenter,ycenter,graindata]=create_tuft_set(labeled,bw,WindAngle);
    
    global MLhandel
    global minNumInCluster
    global featureSelected
    %clusterGrid=[];
    %graindata = regionprops(labeled,'basic');
    %create_grid_for_clustering(I,bw,graindata)
    %     uiwait(gcf)
    gridedindex = MLhandel.clusterGrid.gridindex;
    [gridedimage] = creatgridfromdata(graindata,gridedindex);
    [trainingSet] = buildGridTrainingSet(gridedimage, tuftSet, h, l);
    %clusterGrid=[];
    
    labelDistanceFactor = 4;
    [labeledTufts] = calcCluster(trainingSet,h,l, MLhandel.noMaxClusters, labelDistanceFactor, useUnsupervised);
    
    %%
    
    
end

function [trainingSet] = buildGridTrainingSet(gridedTufts, tuftSet, h, l)
    trainingSetSize = size(gridedTufts);
    trainingSet = zeros(trainingSetSize(1), trainingSetSize(2));
    for i = 1:trainingSetSize(1)
        for j = 1:trainingSetSize(2)
            [data, valid] = getTuftDataByCentroid(tuftSet, gridedTufts(i,j), h, l);
            if(valid)
                trainingSet(i,j) = data;
            end
        end
    end
end

function [tuftData, isValid] = getTuftDataByCentroid(tuftSet, centroid, h, l)
    isValid = false;
    tuftData=[];
    sz = size(tuftSet);
    for ii = 1: sz(1)
        for jj=1:sz(2)
            tuft = tuftSet(ii,jj);
            if(tuft.pixelX*h == centroid(1) && tuft.pixelY*l == centroid(2))
                tuftData = [tuft.pixelX, tuft.pixelY, tuft.windRelatedAngle,...
                    tuft.straightness, tuft.edgeRelatedrealAngle, tuft.length,...
                    tuft.neighbor_1, tuft.neighbor_2, tuft.neighbor_3, tuft.neighbor_4];
                isValid = true;
                return;
            end
        end
    end
end
