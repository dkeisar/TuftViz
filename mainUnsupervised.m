function mainUnsupervised(imageTune,useHybryd)
%UNTITLED3 Summary of this function goes 


%% choose rand image then segment and tune it
[bw,labeled,I] = segmentrandframe(imageTune);

% create_grid_for_clustering(I,bw,labeled,imageTune,flag)
%  uiwait(gcf);

% load ('clusterGrid_for_christ_mov.mat'); 
% global MLhandel;
% MLhandel.gridindex=clusterGrid.gridindex; MLhandel.noMaxCluster=4;
%% Cluster
[tuftSet,labeledTufts] = clusterStepOne(bw,labeled,I,imageTune,useHybryd)
%% here will be the video part
end

