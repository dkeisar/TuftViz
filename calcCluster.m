function [labeledTufts] = calcCluster(trainingSet,h,l, maxClusters, labelDistanceFactor, useHybryd)
addpath(genpath("PRML-PRMLT-v1.7-1-g3f9d968"));
%method = 'Distance';
%subMethod = 'euclidean';

maxClust = maxClusters;
sz = size(trainingSet);
%reduceSet = [];

if ~(useHybryd)
    counter=1;
    for i=1:size(trainingSet,1)
        for j=1:size(trainingSet,2)
            a(counter,1:4)=[trainingSet(i,j,3:6)];
            counter=counter+1;
        end
    end
    Max=max(mean(a));
        Min=min(mean(a));
    [reduceSettag, ~, ~, ~] = pca(a, 1);
    reduceSettag = rescale(reduceSettag,Min,Max);
    counter=1;
    for i=1:size(trainingSet,1)
        for j=1:size(trainingSet,2)
            reduceSet(i,j)=reduceSettag(counter);
            counter=counter+1;
        end
    end
else
    [reduceSet] = calcPredictions(trainingSet);
end

clusterSet = [trainingSet(:,1:2), reduceSet*labelDistanceFactor];
[~, model, ~] = mixGaussEm(clusterSet, maxClust);
[labels, ~] = mixGaussPred(clusterSet, model);
labeledTufts = labels;
flipped = trainingSet;
flipped(:,2) = 1 - trainingSet(:,2);
figure(maxClust);
scatter(flipped(:,1)*l,flipped(:,2)*h,10,labels);
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