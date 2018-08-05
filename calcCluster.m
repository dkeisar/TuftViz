function calcCluster(trainingSet,h,l, maxClusters, labelDistanceFactor)
    %method = 'Distance';
    %subMethod = 'euclidean';
    
    maxClust = maxClusters;
    sz = size(trainingSet);
    [labelCoef,~] = pca(trainingSet(:,3:sz(2)));
    reduceSet = trainingSet(:,3:sz(2)) * labelCoef(:,1);
    clusterSet = [trainingSet(:,1:2), reduceSet*labelDistanceFactor];
    t = kmeans(clusterSet, maxClust);
    flipped = trainingSet;
    flipped(:,2) = 1 - trainingSet(:,2);
    figure(maxClust);
    scatter(flipped(:,1)*l,flipped(:,2)*h,10,t);
    axis equal
    
    if(maxClusters >= 10)
        maxClust = maxClusters + 1;
        t = kmeans(clusterSet, maxClust);
        figure(maxClust);
        scatter(flipped(:,1)*l,flipped(:,2)*h,10,t);
        axis equal
    end
    
    if(maxClusters > 1 || maxClusters >= 10)
        maxClust = maxClusters - 1;
        t = kmeans(clusterSet, maxClust);
        figure(maxClust);
        scatter(flipped(:,1)*l,flipped(:,2)*h,10,t);
        axis equal
    end
    
end