function [outputArg1,outputArg2] = main_clustering(imageTune)
WindAngle=imageTune.FlowAngle;
%% main clustering func
    %% choose rand image then segment and tune it
    [bw,labeled,I] = segmentrandframe(imageTune);
    Orientation=regionprops(labeled,'Orientation');

    %calculate the angle
    for i=1:length(Orientation)
        tuftSet(i).windRelatedAngle=deg2rad((WindAngle-...
            Orientation(i).Orientation));
    end
    global clusterGrid
    %clusterGrid=[];
    graindata = regionprops(labeled,'basic');
    %create_grid_for_clustering(I,bw,graindata)
    %     uiwait(gcf)
    load('clusterGrid_for_christ_mov.mat')
    gridedindex=clusterGrid.gridindex;
    [gridedimage] = creatgridfromdata(graindata,gridedindex);
    %clusterGrid=[];
    
    [h,l]=size(bw);
    maxClusters = 5;
    labelDistanceFactor = 4;
    calcCluster(tuftMat,h,l, maxClusters, labelDistanceFactor);
    
    %%
    
    
end

