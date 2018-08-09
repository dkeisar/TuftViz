function calcCluster(trainingSet,h,l, maxClusters, labelDistanceFactor, useUnsupervised)
    addpath(genpath("PRML-PRMLT-v1.7-1-g3f9d968"));
    %method = 'Distance';
    %subMethod = 'euclidean';
    
    maxClust = maxClusters;
    sz = size(trainingSet);
    %reduceSet = [];
    if(useUnsupervised)
        [reduceSet, ~, ~, ~] = pca(trainingSet(:,3:sz(2)), 1);
    else
        [reduceSet] = calcPredictions(trainingSet);
    end
    clusterSet = [trainingSet(:,1:2), reduceSet*labelDistanceFactor];
    [~, model, ~] = mixGaussEm(clusterSet, maxClust);
    [label, ~] = mixGaussPred(clusterSet, model);
    flipped = trainingSet;
    flipped(:,2) = 1 - trainingSet(:,2);
    figure(maxClust);
    scatter(flipped(:,1)*l,flipped(:,2)*h,10,label);
    axis equal
    
    if(maxClusters <= 10)
        maxClust = maxClusters + 1;
        [~, model, ~] = mixGaussEm(clusterSet, maxClust);
        [label, ~] = mixGaussPred(clusterSet, model);
        figure(maxClust);
        scatter(flipped(:,1)*l,flipped(:,2)*h,10,label);
        axis equal
    end
    
    if(maxClusters > 1 && maxClusters <= 10)
        maxClust = maxClusters - 1;
        [~, model, ~] = mixGaussEm(clusterSet, maxClust);
        [label, ~] = mixGaussPred(clusterSet, model);
        figure(maxClust);
        scatter(flipped(:,1)*l,flipped(:,2)*h,10,label);
        axis equal
    end
    
end

function [answer] = calcPredictions(trainingSet)
    global MLhandel
    localweightVector = MLhandel.weightVector .* MLhandel.weightVector;
    
end