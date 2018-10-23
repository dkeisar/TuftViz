function [labeledTufts] = calcClusters(trainingSet,h,l, noMaxCluster, labelDistanceFactor, useHybryd);% demoNcutClustering
maxClust = noMaxCluster;
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
    [reduceSet] = calcPredictions(trainingSet)*labelDistanceFactor;
end

% compute similarity matrix
[W,Dist] = compute_relation(reduceSet);

% clustering graph in
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(W,noMaxCluster);
disp(['The computation took ' num2str(toc) ' seconds']);
figure(3);
plot(NcutEigenvectors);

% display clustering result
cluster_color = ['rgbmyc'];
figure(2);clf;
for j=1:noMaxCluster,
    id = find(NcutDiscrete(:,j));
    plot(data(1,id),data(2,id),[cluster_color(j),'s'], 'MarkerFaceColor',cluster_color(j),'MarkerSize',5); hold on; 
end
hold off; axis image;
disp('This is the clustering result');
disp('The demo is finished.');
